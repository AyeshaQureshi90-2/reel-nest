
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/movie_model.dart';

class TmdbApiService {
  static Future<List<MovieModel>> searchContent({
    required String query,
    String category = 'All',
  }) async {
    if (query.trim().isEmpty) return [];

    final results = await _request(
      '/search/multi',
      {
        'query': query.trim(),
        'include_adult': 'false',
      },
    );

    final movies = _convertResults(results);

    if (category == 'Movies') {
      return movies.where((item) => item.mediaType == 'movie').toList();
    }

    if (category == 'Anime') {
      return movies.where((item) => item.category == 'Anime').toList();
    }

    if (category == 'Cartoons') {
      return movies.where((item) => item.category == 'Cartoon').toList();
    }

    return movies;
  }

  static Future<List<MovieModel>> fetchTrendingMovies() async {
    final results = await _request('/trending/movie/week', {});
    return _convertResults(
      results,
      forcedCategory: 'Movie',
      forcedMediaType: 'movie',
    );
  }

  static Future<List<MovieModel>> fetchIndianMovies() async {
    final results = await _request(
      '/discover/movie',
      {
        'with_origin_country': 'IN',
        'sort_by': 'popularity.desc',
        'include_adult': 'false',
      },
    );

    return _convertResults(
      results,
      forcedCategory: 'Indian Movie',
      forcedMediaType: 'movie',
    );
  }

  static Future<List<MovieModel>> fetchPakistaniMovies() async {
    final results = await _request(
      '/discover/movie',
      {
        'with_origin_country': 'PK',
        'sort_by': 'popularity.desc',
        'include_adult': 'false',
      },
    );

    return _convertResults(
      results,
      forcedCategory: 'Pakistani Movie',
      forcedMediaType: 'movie',
    );
  }

  static Future<List<MovieModel>> fetchPopularAnime() async {
    final results = await _request(
      '/discover/tv',
      {
        'with_genres': '16',
        'with_original_language': 'ja',
        'sort_by': 'popularity.desc',
      },
    );

    return _convertResults(
      results,
      forcedCategory: 'Anime',
      forcedMediaType: 'tv',
    );
  }

  static Future<List<MovieModel>> fetchIndianCartoons() async {
    final results = await _request(
      '/discover/tv',
      {
        'with_genres': '16',
        'with_origin_country': 'IN',
        'sort_by': 'popularity.desc',
      },
    );

    return _convertResults(
      results,
      forcedCategory: 'Indian Cartoon',
      forcedMediaType: 'tv',
    );
  }

  static Future<List<MovieModel>> fetchPakistaniCartoons() async {
    final results = await _request(
      '/discover/tv',
      {
        'with_genres': '16',
        'with_origin_country': 'PK',
        'sort_by': 'popularity.desc',
      },
    );

    return _convertResults(
      results,
      forcedCategory: 'Pakistani Cartoon',
      forcedMediaType: 'tv',
    );
  }

  static Future<List<MovieModel>> fetchCategoryContent(
    String category,
  ) async {
    switch (category) {
      case 'Trending Movies':
        return fetchTrendingMovies();
      case 'Indian Movies':
        return fetchIndianMovies();
      case 'Pakistani Movies':
        return fetchPakistaniMovies();
      case 'Popular Anime':
        return fetchPopularAnime();
      case 'Indian Cartoons':
        return fetchIndianCartoons();
      case 'Pakistani Cartoons':
        return fetchPakistaniCartoons();
      default:
        return [];
    }
  }

  static Future<String?> fetchYoutubeTrailerKey({
    required int movieId,
    required String mediaType,
  }) async {
    if (mediaType != 'movie' && mediaType != 'tv') {
      return null;
    }

    final results = await _request(
      '/$mediaType/$movieId/videos',
      {},
    );

    final youtubeTrailers = results.where((item) {
      final video = item as Map<String, dynamic>;

      return video['site'] == 'YouTube' &&
          video['type'] == 'Trailer' &&
          video['key'] != null &&
          (video['key'] as String).isNotEmpty;
    }).toList();

    if (youtubeTrailers.isEmpty) {
      return null;
    }

    youtubeTrailers.sort((a, b) {
      final firstOfficial =
          (a as Map<String, dynamic>)['official'] == true;
      final secondOfficial =
          (b as Map<String, dynamic>)['official'] == true;

      if (firstOfficial == secondOfficial) {
        return 0;
      }

      return firstOfficial ? -1 : 1;
    });

    final trailer = youtubeTrailers.first as Map<String, dynamic>;

    return trailer['key'] as String;
  }

  static Future<List<dynamic>> _request(
    String endpoint,
    Map<String, String> parameters,
  ) async {
    if (ApiConfig.tmdbApiKey.isEmpty) {
      throw Exception('TMDB API key is missing.');
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}$endpoint',
    ).replace(
      queryParameters: {
        'api_key': ApiConfig.tmdbApiKey,
        'language': 'en-US',
        'page': '1',
        ...parameters,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('TMDB API Error: ${response.statusCode}');
    }

    final decodedData =
        jsonDecode(response.body) as Map<String, dynamic>;

    return decodedData['results'] as List<dynamic>? ?? [];
  }

  static List<MovieModel> _convertResults(
    List<dynamic> results, {
    String? forcedCategory,
    String? forcedMediaType,
  }) {
    final List<MovieModel> movies = [];

    for (final item in results) {
      final result = item as Map<String, dynamic>;

      final mediaType = forcedMediaType ??
          (result['media_type'] as String? ?? 'movie');

      if (mediaType != 'movie' && mediaType != 'tv') {
        continue;
      }

      final genreIds = result['genre_ids'] as List<dynamic>? ?? [];
      final isAnimation = genreIds.contains(16);
      final language = result['original_language'] as String? ?? '';

      String category = forcedCategory ?? 'Movie';

      if (forcedCategory == null) {
        if (mediaType == 'tv') {
          category = 'TV Show';
        }

        if (isAnimation && language == 'ja') {
          category = 'Anime';
        } else if (isAnimation) {
          category = 'Cartoon';
        }
      }

      movies.add(
        MovieModel(
          id: result['id'] as int,
          title: result['title'] as String? ??
              result['name'] as String? ??
              'Untitled',
          posterPath: result['poster_path'] as String? ?? '',
          category: category,
          overview: result['overview'] as String? ?? '',
          releaseDate: result['release_date'] as String? ??
              result['first_air_date'] as String? ??
              '',
          mediaType: mediaType,
        ),
      );
    }

    return movies;
  }
}
