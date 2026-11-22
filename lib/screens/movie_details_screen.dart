import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/movie_model.dart';
import '../services/tmdb_api_service.dart';

class MovieDetailsScreen extends StatefulWidget {
  final MovieModel movie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
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

  String? trailerKey;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrailer();
  }

  Future<void> _loadTrailer() async {
    try {
      final key = await TmdbApiService.fetchYoutubeTrailerKey(
        movieId: widget.movie.id,
        mediaType: widget.movie.mediaType,
      );

      if (!mounted) return;

      setState(() {
        trailerKey = key;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load trailer right now.';
      });
    }
  }

  void _watchTrailer() {
    if (trailerKey == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrailerPlayerScreen(
          trailerKey: trailerKey!,
          movieTitle: widget.movie.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

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
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: movie.fullPosterUrl.isNotEmpty
                    ? Image.network(
                        movie.fullPosterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _posterPlaceholder(),
                      )
                    : _posterPlaceholder(),
              ),
            ),

            const SizedBox(height: 22),

            Text(
              movie.title,
              style: const TextStyle(
                color: peach,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _infoChip(movie.category),
                if (movie.releaseDate.isNotEmpty)
                  _infoChip(movie.releaseDate),
                _infoChip(
                  movie.mediaType == 'tv' ? 'TV Show' : 'Movie',
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Overview',
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              movie.overview.isNotEmpty
                  ? movie.overview
                  : 'No description available.',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 15,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: trailerKey == null ? null : _watchTrailer,
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

            const SizedBox(height: 12),

            if (isLoading)
              const Center(
                child: CircularProgressIndicator(color: peach),
              )
            else if (errorMessage != null)
              Text(
                errorMessage!,
                style: TextStyle(color: secondaryTextColor),
              )
            else if (trailerKey == null)
              Text(
                'No YouTube trailer is available for this title.',
                style: TextStyle(color: secondaryTextColor),
              ),
          ],
        ),
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
}

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