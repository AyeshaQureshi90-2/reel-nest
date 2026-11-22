
class MovieModel {
  final int id;
  final String title;
  final String posterPath;
  final String category;
  final String overview;
  final String releaseDate;
  final String mediaType;

  const MovieModel({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.category,
    required this.overview,
    required this.releaseDate,
    this.mediaType = 'movie',
  });

  String get fullPosterUrl {
    if (posterPath.isEmpty) {
      return '';
    }

    if (posterPath.startsWith('http')) {
      return posterPath;
    }

    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'category': category,
      'overview': overview,
      'releaseDate': releaseDate,
      'mediaType': mediaType,
    };
  }

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled',
      posterPath: json['posterPath'] as String? ?? '',
      category: json['category'] as String? ?? 'Movie',
      overview: json['overview'] as String? ?? '',
      releaseDate: json['releaseDate'] as String? ?? '',
      mediaType: json['mediaType'] as String? ?? 'movie',
    );
  }
}
