class MediaItem {
  final String id;
  final String title;
  final String image;
  final String rating;
  final String year;
  final String category;
  final String type;
  final String description;
  final String genres;
  final String duration;
  final List<dynamic> similar;

  const MediaItem({
    required this.id,
    required this.title,
    required this.image,
    required this.rating,
    required this.year,
    required this.category,
    required this.type,
    required this.description,
    required this.genres,
    required this.duration,
    required this.similar,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "image": image,
      "rating": rating,
      "year": year,
      "category": category,
      "type": type,
      "description": description,
      "genres": genres,
      "duration": duration,
      "similar": similar,
    };
  }

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map["id"] ?? "",
      title: map["title"] ?? "",
      image: map["image"] ?? "",
      rating: map["rating"] ?? "",
      year: map["year"] ?? "",
      category: map["category"] ?? "",
      type: map["type"] ?? "",
      description: map["description"] ?? "",
      genres: map["genres"] ?? "",
      duration: map["duration"] ?? "",
      similar: map["similar"] ?? [],
    );
  }
}
