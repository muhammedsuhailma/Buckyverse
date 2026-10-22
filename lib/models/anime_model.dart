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
    final titleData = json['title'] as Map<String, dynamic>?;

    final title = titleData?['english']?.toString().trim().isNotEmpty == true
        ? titleData!['english'].toString()
        : titleData?['romaji']?.toString() ??
              titleData?['native']?.toString() ??
              'Unknown Anime';

    final coverImage = json['coverImage'] as Map<String, dynamic>?;
    final image =
        coverImage?['extraLarge']?.toString() ??
        coverImage?['large']?.toString() ??
        coverImage?['medium']?.toString() ??
        '';

    final startDate = json['startDate'] as Map<String, dynamic>?;
    final year = int.tryParse(startDate?['year']?.toString() ?? '') ?? 0;

    final genres =
        (json['genres'] as List?)
            ?.map((genre) => genre.toString())
            .where((genre) => genre.isNotEmpty)
            .toList() ??
        <String>[];

    return AnimeModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: title,
      image: image,
      rating: ((json['averageScore'] as num?)?.toDouble() ?? 0.0) / 10,
      synopsis: json['description']?.toString() ?? '',
      year: year,
      genres: genres,
    );
  }
}
