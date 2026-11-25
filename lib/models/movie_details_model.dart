
class MovieDetailsModel {
  final int id;
  final String title;
  final String overview;
  final String tagline;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double rating;
  final List<String> genres;
  final int? runtime;
  final String status;
  final String originalLanguage;
  final String director;
  final List<CastMember> cast;

  const MovieDetailsModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.tagline,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.rating,
    required this.genres,
    required this.runtime,
    required this.status,
    required this.originalLanguage,
    required this.director,
    required this.cast,
  });

  String get fullPosterUrl {
    if (posterPath.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get fullBackdropUrl {
    if (backdropPath.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w1280$backdropPath';
  }

  factory MovieDetailsModel.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? credits,
    required String mediaType,
  }) {
    final genreList = json['genres'] as List<dynamic>? ?? [];

    final castList =
        credits?['cast'] as List<dynamic>? ?? [];

    final crewList =
        credits?['crew'] as List<dynamic>? ?? [];

    final directorMember = crewList.cast<Map<String, dynamic>>().where(
      (member) => member['job'] == 'Director',
    );

    final episodeRuntimes =
        json['episode_run_time'] as List<dynamic>? ?? [];

    int? runtime;

    if (json['runtime'] is num) {
      runtime = (json['runtime'] as num).toInt();
    } else if (episodeRuntimes.isNotEmpty &&
        episodeRuntimes.first is num) {
      runtime = (episodeRuntimes.first as num).toInt();
    }

    return MovieDetailsModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ??
          json['name'] as String? ??
          'Untitled',
      overview: json['overview'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      backdropPath: json['backdrop_path'] as String? ?? '',
      releaseDate: json['release_date'] as String? ??
          json['first_air_date'] as String? ??
          '',
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      genres: genreList
          .map((genre) =>
              (genre as Map<String, dynamic>)['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
      runtime: runtime,
      status: json['status'] as String? ?? '',
      originalLanguage:
          json['original_language'] as String? ?? '',
      director: directorMember.isNotEmpty
          ? directorMember.first['name'] as String? ?? ''
          : '',
      cast: castList
          .take(15)
          .map(
            (member) => CastMember.fromJson(
              member as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class CastMember {
  final int id;
  final String name;
  final String character;
  final String profilePath;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
  });

  String get fullProfileUrl {
    if (profilePath.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w185$profilePath';
  }

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      character: json['character'] as String? ?? '',
      profilePath: json['profile_path'] as String? ?? '',
    );
  }
}
