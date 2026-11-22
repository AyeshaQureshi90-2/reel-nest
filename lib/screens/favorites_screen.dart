import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../services/favorites_service.dart';
import 'movie_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const Color peach = Color(0xFFFDBA9B);
  static const Color silver = Color(0xFFCBD5E1);
  static const Color dark = Color(0xFF08090D);

  bool get isDarkMode =>
      Theme.of(context).brightness == Brightness.dark;

  Color get pageBackground =>
      isDarkMode ? dark : const Color(0xFFF4F5F7);

  Color get surfaceColor =>
      isDarkMode ? const Color(0xFF1C1B22) : Colors.white;

  Color get placeholderColor =>
      isDarkMode ? const Color(0xFF29202A) : const Color(0xFFE1E3E8);

  Color get primaryTextColor =>
      isDarkMode ? silver : const Color(0xFF252525);

  Color get secondaryTextColor =>
      isDarkMode ? Colors.white54 : Colors.black54;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeFavorites();
  }

  Future<void> initializeFavorites() async {
    await FavoritesService.initialize();

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> removeFavorite(MovieModel movie) async {
    await FavoritesService.removeFavorite(
      movie.id,
      mediaType: movie.mediaType,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from Favorites'),
        backgroundColor: surfaceColor,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        title: Text(
          'My Favorites',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: peach,
                ),
              )
            : ValueListenableBuilder<List<MovieModel>>(
                valueListenable:
                    FavoritesService.favoritesNotifier,
                builder: (context, favorites, child) {
                  if (favorites.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildFavoritesList(favorites);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(35),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: peach,
                size: 65,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Your Favorites',
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Save your favorite movies, anime and cartoons here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No Favorites Yet',
              style: TextStyle(
                color: peach,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(List<MovieModel> favorites) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final movie = favorites[index];

        return GestureDetector(
          onTap: () => openMovieDetails(movie),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 105,
                    width: 75,
                    color: placeholderColor,
                    child: movie.fullPosterUrl.isNotEmpty
                        ? Image.network(
                            movie.fullPosterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.movie_rounded,
                                color: peach,
                                size: 35,
                              );
                            },
                          )
                        : const Icon(
                            Icons.movie_rounded,
                            color: peach,
                            size: 35,
                          ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        '',
                        style: TextStyle(fontSize: 0),
                      ),
                      Text(
                        movie.category,
                        style: const TextStyle(
                          color: peach,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        movie.releaseDate.isNotEmpty
                            ? movie.releaseDate
                            : 'Release date unavailable',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => removeFavorite(movie),
                  icon: const Icon(
                    Icons.favorite_rounded,
                    color: peach,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}