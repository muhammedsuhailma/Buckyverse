class AnimeModel {
  final int id;
  final String title;
  final String image;
  final double rating;
  final String synopsis;
  final int year;
  final List<String> genres;
  AnimeModel({
    required this.id,
    required this.title,
    required this.image,
    required this.rating,
    required this.synopsis,
    required this.year,
    required this.genres,
  });

  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map<String, dynamic>?;
    final jpg = images?['jpg'] as Map<String, dynamic>?;
    final imageUrl = jpg?['large_image_url'] ?? jpg?['image_url'] ?? '';

    final genresList = (json['genres'] as List?)
            ?.map((g) => g['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList() ??
        <String>[];

    int parsedYear = 0;
    if (json['year'] != null) {
      parsedYear = int.tryParse(json['year'].toString()) ?? 0;
    } else if (json['aired'] != null &&
        json['aired']['prop'] != null &&
        json['aired']['prop']['from'] != null &&
        json['aired']['prop']['from']['year'] != null) {
      parsedYear =
          int.tryParse(json['aired']['prop']['from']['year'].toString()) ?? 0;
    }

    return AnimeModel(
      id: json['mal_id'] is int
          ? json['mal_id']
          : int.tryParse(json['mal_id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      image: imageUrl.toString(),
      rating: (json['score'] as num?)?.toDouble() ?? 0.0,
      synopsis: json['synopsis']?.toString() ?? '',
      year: parsedYear,
      genres: genresList,
    );
  }
}
