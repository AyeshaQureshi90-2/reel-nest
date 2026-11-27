
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../services/tmdb_api_service.dart';
import '../services/favorites_service.dart';
import 'movie_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final bool isGuest;
  final VoidCallback? onRequireLogin;

  const SearchScreen({
    super.key,
    this.isGuest = false,
    this.onRequireLogin,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Color peach = Color(0xFFFDBA9B);
  static const Color silver = Color(0xFFCBD5E1);
  static const Color dark = Color(0xFF08090D);

  bool get isDarkMode =>
      Theme.of(context).brightness == Brightness.dark;

  Color get pageBackground =>
      isDarkMode ? dark : const Color(0xFFF4F5F7);

  Color get surfaceColor =>
      isDarkMode ? const Color(0xFF1C1B22) : Colors.white;

  Color get primaryTextColor =>
      isDarkMode ? silver : const Color(0xFF252525);

  Color get secondaryTextColor =>
      isDarkMode ? Colors.white54 : Colors.black54;

  final TextEditingController searchController =
      TextEditingController();

  Timer? _debounce;

  String selectedCategory = 'All';

  bool isLoading = false;
  String? errorMessage;

  List<MovieModel> searchResults = [];

  int _requestId = 0;

  final List<String> categories = [
    'All',
    'Movies',
    'Anime',
    'Cartoons',
  ];

  @override
  void initState() {
    super.initState();
    FavoritesService.initialize();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      _requestId++;

      setState(() {
        searchResults = [];
        isLoading = false;
        errorMessage = null;
      });

      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        _searchContent(query);
      },
    );
  }

  Future<void> _searchContent(String query) async {
    if (query.trim().isEmpty) return;

    final currentRequest = ++_requestId;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await TmdbApiService.searchContent(
        query: query,
        category: selectedCategory,
      );

      if (!mounted || currentRequest != _requestId) return;

      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted || currentRequest != _requestId) return;

      setState(() {
        searchResults = [];
        isLoading = false;
        errorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
      });
    }
  }

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });

    if (searchController.text.trim().isNotEmpty) {
      _debounce?.cancel();
      _searchContent(searchController.text);
    }
  }

  void _clearSearch() {
    _debounce?.cancel();
    _requestId++;

    searchController.clear();

    setState(() {
      searchResults = [];
      isLoading = false;
      errorMessage = null;
    });
  }

  Future<void> _toggleFavorite(MovieModel movie) async {
    if (widget.isGuest) {
      widget.onRequireLogin?.call();
      return;
    }

    final isAlreadyFavorite =
        FavoritesService.favoritesNotifier.value.any(
      (item) =>
          item.id == movie.id &&
          item.mediaType == movie.mediaType,
    );

    if (isAlreadyFavorite) {
      await FavoritesService.removeFavorite(
        movie.id,
        mediaType: movie.mediaType,
      );
    } else {
      await FavoritesService.addFavorite(movie);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAlreadyFavorite
              ? 'Removed from Favorites'
              : 'Added to Favorites',
        ),
        backgroundColor: surfaceColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openMovieDetails(MovieModel movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(
          movie: movie,
          isGuest: widget.isGuest,
          onRequireLogin: widget.onRequireLogin,
        ),
      ),
    );
  }

  Widget _buildSearchResult(MovieModel movie) {
    return GestureDetector(
      onTap: () => _openMovieDetails(movie),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: peach.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: SizedBox(
                width: 105,
                height: 145,
                child: movie.fullPosterUrl.isNotEmpty
                    ? Image.network(
                        movie.fullPosterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _posterPlaceholder();
                        },
                      )
                    : _posterPlaceholder(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.category,
                      style: const TextStyle(
                        color: peach,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      movie.releaseDate.isNotEmpty
                          ? movie.releaseDate
                          : 'Release date unavailable',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview.isNotEmpty
                          ? movie.overview
                          : 'No description available.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder<List<MovieModel>>(
              valueListenable: FavoritesService.favoritesNotifier,
              builder: (context, favorites, child) {
                final isFavorite = favorites.any(
                  (item) =>
                      item.id == movie.id &&
                      item.mediaType == movie.mediaType,
                );

                return IconButton(
                  onPressed: () => _toggleFavorite(movie),
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: peach,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      color: isDarkMode
          ? const Color(0xFF292832)
          : const Color(0xFFE1E3E8),
      child: const Center(
        child: Icon(
          Icons.movie_rounded,
          color: peach,
          size: 35,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 45),
        child: Column(
          children: [
            const Icon(
              Icons.movie_filter_rounded,
              color: peach,
              size: 65,
            ),
            const SizedBox(height: 15),
            Text(
              'Explore ReelNest',
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your favorite stories are waiting for you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(
            color: peach,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 35),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: peach,
                size: 45,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  _searchContent(searchController.text);
                },
                child: const Text(
                  'Try Again',
                  style: TextStyle(color: peach),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (searchController.text.trim().isEmpty) {
      return _buildEmptyState();
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const Icon(
                Icons.search_off_rounded,
                color: peach,
                size: 50,
              ),
              const SizedBox(height: 12),
              Text(
                'No results found',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try another search or category.',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: searchResults
          .map(_buildSearchResult)
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        title: Text(
          'Discover',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Your Next Favorite',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search movies, anime and cartoons.',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 25),
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: peach.withValues(alpha: 0.35),
                  ),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: _searchContent,
                  style: TextStyle(color: primaryTextColor),
                  cursorColor: peach,
                  decoration: InputDecoration(
                    hintText: 'Search movies, anime...',
                    hintStyle: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: peach,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _clearSearch,
                      icon: Icon(
                        Icons.close_rounded,
                        color: primaryTextColor,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 17,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Browse Categories',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected =
                        selectedCategory == category;

                    return GestureDetector(
                      onTap: () {
                        _selectCategory(category);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? peach
                              : surfaceColor,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? dark : primaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              if (searchResults.isNotEmpty &&
                  !isLoading &&
                  errorMessage == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(
                    '${searchResults.length} results found',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              _buildResultsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
