
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/movie_model.dart';
import '../models/movie_details_model.dart';
import '../services/tmdb_api_service.dart';

// PROVIDER: Manages movie details, recommendations and trailer state.
class MovieDetailsProvider extends ChangeNotifier {
  final MovieModel movie;

  MovieDetailsProvider(this.movie);

  MovieDetailsModel? details;
  List<MovieModel> similarMovies = [];

  String? trailerKey;
  String? errorMessage;

  bool isLoading = true;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      details = await TmdbApiService.fetchMovieDetails(
        movieId: movie.id,
        mediaType: movie.mediaType,
      );
    } catch (e) {
      errorMessage = 'Unable to load complete movie details.';
    }

    try {
      similarMovies = await TmdbApiService.fetchSimilarMovies(
        movieId: movie.id,
        mediaType: movie.mediaType,
      );
    } catch (_) {
      similarMovies = [];
    }

    try {
      trailerKey = await TmdbApiService.fetchYoutubeTrailerKey(
        movieId: movie.id,
        mediaType: movie.mediaType,
      );
    } catch (_) {
      trailerKey = null;
    }

    isLoading = false;
    notifyListeners();
  }
}

class MovieDetailsScreen extends StatefulWidget {
  final MovieModel movie;
  final bool isGuest;
  final VoidCallback? onRequireLogin;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
    this.isGuest = false,
    this.onRequireLogin,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  static const Color peach = Color(0xFFFDBA9B);
  static const Color silver = Color(0xFFCBD5E1);
  static const Color dark = Color(0xFF08090D);

  bool get isDarkMode =>
      Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDarkMode ? dark : Colors.white;

  Color get primaryTextColor =>
      isDarkMode ? Colors.white : const Color(0xFF20232A);

  Color get secondaryTextColor =>
      isDarkMode ? silver : const Color(0xFF555B66);

  Color get placeholderColor =>
      isDarkMode ? const Color(0xFF20232A) : const Color(0xFFE8ECF1);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MovieDetailsProvider(widget.movie)..load(),
      child: Consumer<MovieDetailsProvider>(
        builder: (context, provider, child) {
          final movie = widget.movie;
          final details = provider.details;

          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: backgroundColor,
              foregroundColor: secondaryTextColor,
              title: const Text('Movie Details'),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPoster(movie, details),

                  const SizedBox(height: 22),

                  Text(
                    details?.title ?? movie.title,
                    style: const TextStyle(
                      color: peach,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (details?.tagline.isNotEmpty == true) ...[
                    const SizedBox(height: 7),
                    Text(
                      details!.tagline,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _infoChip(movie.category),
                      _infoChip(
                        movie.mediaType == 'tv' ? 'TV Show' : 'Movie',
                      ),
                      if (details != null && details.rating > 0)
                        _infoChip(
                          '★ ${details.rating.toStringAsFixed(1)} / 10',
                        ),
                      if (movie.releaseDate.isNotEmpty)
                        _infoChip(movie.releaseDate),
                    ],
                  ),

                  const SizedBox(height: 25),

                  if (provider.isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: peach),
                    ),

                  if (provider.errorMessage != null) ...[
                    Text(
                      provider.errorMessage!,
                      style: TextStyle(color: secondaryTextColor),
                    ),
                    const SizedBox(height: 8),
                  ],

                  _sectionTitle('Overview'),

                  const SizedBox(height: 10),

                  Text(
                    details?.overview.isNotEmpty == true
                        ? details!.overview
                        : movie.overview.isNotEmpty
                            ? movie.overview
                            : 'No description available.',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  if (details != null) ...[
                    const SizedBox(height: 28),

                    _sectionTitle('Movie Information'),

                    const SizedBox(height: 12),

                    _detailRow('Release Date', details.releaseDate),
                    _detailRow(
                      'Runtime',
                      details.runtime != null
                          ? '${details.runtime} minutes'
                          : 'Not available',
                    ),
                    _detailRow('Status', details.status),
                    _detailRow('Language', details.originalLanguage),
                    _detailRow('Director', details.director),

                    if (details.genres.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _sectionTitle('Genres'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: details.genres
                            .map((genre) => _infoChip(genre))
                            .toList(),
                      ),
                    ],

                    if (details.cast.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      _sectionTitle('Cast'),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 190,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: details.cast.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 13),
                          itemBuilder: (context, index) {
                            final member = details.cast[index];

                            return SizedBox(
                              width: 105,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 105,
                                      height: 120,
                                      child: member.fullProfileUrl.isNotEmpty
                                          ? Image.network(
                                              member.fullProfileUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  _personPlaceholder(),
                                            )
                                          : _personPlaceholder(),
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    member.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: primaryTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    member.character,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: provider.trailerKey == null
                          ? null
                          : () {
                              if (widget.isGuest) {
                                widget.onRequireLogin?.call();
                                return;
                              }

                              _watchTrailer(
                                provider.trailerKey!,
                                movie.title,
                              );
                            },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Watch Trailer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: peach,
                        foregroundColor: dark,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  if (!provider.isLoading &&
                      provider.trailerKey == null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'No YouTube trailer is available for this title.',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  ],

                  if (provider.similarMovies.isNotEmpty) ...[
                    const SizedBox(height: 32),

                    _sectionTitle('You May Also Like'),

                    const SizedBox(height: 14),

                    SizedBox(
                      height: 225,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.similarMovies.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: 13),
                        itemBuilder: (context, index) {
                          final similar = provider.similarMovies[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MovieDetailsScreen(
                                    movie: similar,
                                    isGuest: widget.isGuest,
                                    onRequireLogin:
                                        widget.onRequireLogin,
                                  ),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: 125,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 125,
                                      height: 170,
                                      child: similar.fullPosterUrl.isNotEmpty
                                          ? Image.network(
                                              similar.fullPosterUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  _posterPlaceholder(),
                                            )
                                          : _posterPlaceholder(),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    similar.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: primaryTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _watchTrailer(String key, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrailerPlayerScreen(
          trailerKey: key,
          movieTitle: title,
        ),
      ),
    );
  }

  Widget _buildPoster(MovieModel movie, MovieDetailsModel? details) {
    final imageUrl = details?.fullBackdropUrl.isNotEmpty == true
        ? details!.fullBackdropUrl
        : movie.fullPosterUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _posterPlaceholder(),
              )
            : _posterPlaceholder(),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: primaryTextColor,
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: TextStyle(
                color: secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not available',
              style: TextStyle(color: primaryTextColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: peach.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: peach.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: peach,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      color: placeholderColor,
      child: Center(
        child: Icon(
          Icons.movie,
          color: secondaryTextColor,
          size: 65,
        ),
      ),
    );
  }

  Widget _personPlaceholder() {
    return Container(
      color: placeholderColor,
      child: Center(
        child: Icon(
          Icons.person,
          color: secondaryTextColor,
          size: 45,
        ),
      ),
    );
  }
}

// Existing YouTube trailer player.
class TrailerPlayerScreen extends StatefulWidget {
  final String trailerKey;
  final String movieTitle;

  const TrailerPlayerScreen({
    super.key,
    required this.trailerKey,
    required this.movieTitle,
  });

  @override
  State<TrailerPlayerScreen> createState() =>
      _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<TrailerPlayerScreen> {
  late final YoutubePlayerController controller;

  bool get isDarkMode =>
      Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDarkMode ? const Color(0xFF08090D) : Colors.white;

  Color get textColor =>
      isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF20232A);

  @override
  void initState() {
    super.initState();

    controller = YoutubePlayerController.fromVideoId(
      videoId: widget.trailerKey,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        title: Text(
          '${widget.movieTitle} Trailer',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: YoutubePlayer(
          controller: controller,
          aspectRatio: 16 / 9,
          autoFullScreen: true,
        ),
      ),
    );
  }
}
