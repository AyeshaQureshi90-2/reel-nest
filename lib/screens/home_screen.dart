
import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../services/favorites_service.dart';
import '../services/tmdb_api_service.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'category_screen.dart';
import 'movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color peach = Color(0xFFFDBA9B);
  static const Color silver = Color(0xFFCBD5E1);
  static const Color dark = Color(0xFF08090D);

  bool get isDarkMode =>
      Theme.of(context).brightness == Brightness.dark;

  Color get pageBackground =>
      isDarkMode ? dark : const Color(0xFFF4F5F7);

  Color get surfaceColor =>
      isDarkMode ? const Color(0xFF15141A) : Colors.white;

  Color get cardColor =>
      isDarkMode ? const Color(0xFF1C1B22) : const Color(0xFFE8EAF0);

  Color get primaryTextColor =>
      isDarkMode ? silver : const Color(0xFF252525);

  Color get secondaryTextColor =>
      isDarkMode ? Colors.white54 : Colors.black54;

  int selectedCategory = 0;
  int selectedTab = 0;

  final List<String> categories = [
    'All',
    'Movies',
    'Anime',
    'Cartoons',
  ];

  late Future<List<MovieModel>> trendingMovies;
  late Future<List<MovieModel>> indianMovies;
  late Future<List<MovieModel>> pakistaniMovies;
  late Future<List<MovieModel>> popularAnime;
  late Future<List<MovieModel>> indianCartoons;
  late Future<List<MovieModel>> pakistaniCartoons;

  @override
  void initState() {
    super.initState();

    _loadHomeContent();
    FavoritesService.initialize();
  }

  void _loadHomeContent() {
    trendingMovies = TmdbApiService.fetchTrendingMovies();
    indianMovies = TmdbApiService.fetchIndianMovies();
    pakistaniMovies = TmdbApiService.fetchPakistaniMovies();
    popularAnime = TmdbApiService.fetchPopularAnime();
    indianCartoons = TmdbApiService.fetchIndianCartoons();
    pakistaniCartoons = TmdbApiService.fetchPakistaniCartoons();
  }

  void changeTab(int index) {
    setState(() {
      selectedTab = index;
    });
  }

  Future<void> toggleFavorite(MovieModel movie) async {
    await FavoritesService.initialize();

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
              ? '${movie.title} removed from Favorites'
              : '${movie.title} added to Favorites',
        ),
        backgroundColor: surfaceColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void openMovieDetails(MovieModel movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movie: movie),
      ),
    );
  }

  void openCategory(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryScreen(
          categoryTitle: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: IndexedStack(
        index: selectedTab,
        children: [
          _buildHomeContent(),
          const SearchScreen(),
          const FavoritesScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab,
        onTap: changeTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: surfaceColor,
        selectedItemColor: peach,
        unselectedItemColor: primaryTextColor,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.movie_creation_rounded,
                    color: peach,
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Reel',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Nest',
                    style: TextStyle(
                      color: peach,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => changeTab(1),
                    icon: const Icon(
                      Icons.search_rounded,
                      color: peach,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Text(
                'Welcome to ReelNest',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Discover your next favorite story.',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 25),
              _buildFeaturedBanner(),
              const SizedBox(height: 30),
              Text(
                'Categories',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildCategoryChips(),
              const SizedBox(height: 30),
              _buildSectionTitle('Trending Movies'),
              const SizedBox(height: 15),
              _buildMovieSection(trendingMovies),
              const SizedBox(height: 30),
              _buildSectionTitle('Indian Movies'),
              const SizedBox(height: 15),
              _buildMovieSection(indianMovies),
              const SizedBox(height: 30),
              _buildSectionTitle('Pakistani Movies'),
              const SizedBox(height: 15),
              _buildMovieSection(pakistaniMovies),
              const SizedBox(height: 30),
              _buildSectionTitle('Popular Anime'),
              const SizedBox(height: 15),
              _buildMovieSection(popularAnime),
              const SizedBox(height: 30),
              _buildSectionTitle('Indian Cartoons'),
              const SizedBox(height: 15),
              _buildMovieSection(indianCartoons),
              const SizedBox(height: 30),
              _buildSectionTitle('Pakistani Cartoons'),
              const SizedBox(height: 15),
              _buildMovieSection(pakistaniCartoons),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF704B49),
            Color(0xFF29202A),
            Color(0xFF15151D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 15,
            top: 25,
            child: Icon(
              Icons.movie_filter_rounded,
              color: peach.withValues(alpha: 0.35),
              size: 125,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'FEATURED',
                  style: TextStyle(
                    color: peach,
                    fontSize: 12,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Explore Amazing\nMovies & Stories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () => changeTab(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: peach,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Explore Now',
                      style: TextStyle(
                        color: dark,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = selectedCategory == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = index;
              });

              if (index != 0) {
                changeTab(1);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected ? peach : cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? peach
                      : (isDarkMode ? Colors.white12 : Colors.black12),
                ),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? dark : primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () => openCategory(title),
          child: const Text(
            'See All',
            style: TextStyle(
              color: peach,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieSection(
    Future<List<MovieModel>> future,
  ) {
    return SizedBox(
      height: 195,
      child: FutureBuilder<List<MovieModel>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: peach),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load content. Please try again.',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                ),
              ),
            );
          }

          final movies = snapshot.data ?? [];

          if (movies.isEmpty) {
            return Center(
              child: Text(
                'No content available right now.',
                style: TextStyle(color: secondaryTextColor),
              ),
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final movie = movies[index];

              return GestureDetector(
                onTap: () => openMovieDetails(movie),
                child: Container(
                  width: 125,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (movie.fullPosterUrl.isNotEmpty)
                        Image.network(
                          movie.fullPosterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.movie_outlined,
                              color: peach,
                              size: 45,
                            );
                          },
                        )
                      else
                        const Center(
                          child: Icon(
                            Icons.movie_outlined,
                            color: peach,
                            size: 45,
                          ),
                        ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(7, 22, 7, 9),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black87,
                              ],
                            ),
                          ),
                          child: Text(
                            movie.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: ValueListenableBuilder<List<MovieModel>>(
                          valueListenable:
                              FavoritesService.favoritesNotifier,
                          builder: (context, favorites, child) {
                            final isFavorite = favorites.any(
                              (item) =>
                                  item.id == movie.id &&
                                  item.mediaType == movie.mediaType,
                            );

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () => toggleFavorite(movie),
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: isFavorite ? peach : Colors.white,
                                  size: 19,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

