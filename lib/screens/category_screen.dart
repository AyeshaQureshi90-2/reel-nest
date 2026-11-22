import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../services/favorites_service.dart';
import '../services/tmdb_api_service.dart';
import 'movie_details_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryTitle;

  const CategoryScreen({
    super.key,
    required this.categoryTitle,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  static const Color peach = Color(0xFFFDBA9B);
  static const Color silver = Color(0xFFCBD5E1);
  static const Color dark = Color(0xFF08090D);

  late Future<List<MovieModel>> contentFuture;

  bool get isDarkMode =>
      Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDarkMode ? dark : const Color(0xFFF4F5F7);

  Color get cardColor =>
      isDarkMode ? const Color(0xFF1C1B22) : Colors.white;

  Color get primaryTextColor =>
      isDarkMode ? silver : const Color(0xFF252525);

  Color get secondaryTextColor =>
      isDarkMode ? Colors.white54 : Colors.black54;

  @override
  void initState() {
    super.initState();
    contentFuture = TmdbApiService.fetchCategoryContent(
      widget.categoryTitle,
    );
    FavoritesService.initialize();
  }

  Future<void> toggleFavorite(MovieModel movie) async {
    await FavoritesService.initialize();

    final alreadyFavorite =
        FavoritesService.favoritesNotifier.value.any(
      (item) =>
          item.id == movie.id &&
          item.mediaType == movie.mediaType,
    );

    if (alreadyFavorite) {
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
          alreadyFavorite
              ? '${movie.title} removed from Favorites'
              : '${movie.title} added to Favorites',
          style: TextStyle(
            color: primaryTextColor,
          ),
        ),
        backgroundColor: cardColor,
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

  void retryLoading() {
    setState(() {
      contentFuture = TmdbApiService.fetchCategoryContent(
        widget.categoryTitle,
      );
    });
  }

  Widget buildMovieCard(MovieModel movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => openMovieDetails(movie),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
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
                          size: 40,
                        );
                      },
                    )
                  else
                    const Icon(
                      Icons.movie_outlined,
                      color: peach,
                      size: 40,
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
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
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => toggleFavorite(movie),
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite ? peach : Colors.white,
                              size: 18,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 34,
                              minHeight: 34,
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
          ),
        ),
        const SizedBox(height: 7),
        Text(
          movie.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: peach),
        title: Text(
          widget.categoryTitle,
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<MovieModel>>(
        future: contentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: peach),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      color: peach,
                      size: 55,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Unable to load content',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your internet connection and try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: secondaryTextColor),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: retryLoading,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: peach,
                        foregroundColor: dark,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final movies = snapshot.data ?? [];

          if (movies.isEmpty) {
            return Center(
              child: Text(
                'No content available right now.',
                style: TextStyle(color: primaryTextColor),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: movies.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 18,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return buildMovieCard(movie);
            },
          );
        },
      ),
    );
  }
}