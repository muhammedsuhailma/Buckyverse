class BucketItem {
  final String id;
  final Map<String, dynamic> data;
  String status;
  bool isFavorite;

  BucketItem({
    required this.id,
    required this.data,
    this.status = "Planning",
    this.isFavorite = false,
  });

  BucketItem copyWith({String? status, bool? isFavorite}) {
    return BucketItem(
      id: id,
      data: data,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Convert to Firestore
  Map<String, dynamic> toMap() {
    return {'id': id, 'data': data, 'status': status, 'isFavorite': isFavorite};
  }

  factory BucketItem.fromMap(Map<String, dynamic> map) {
    final rawData = map['data'];
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};

    final genres = data['genres'];

    if (genres is String) {
      data['genres'] = genres.isEmpty
          ? <String>[]
          : genres.split(',').map((e) => e.trim()).toList();
    }

    return BucketItem(
      id: (map['id'] ?? data['title'] ?? "").toString(),
      data: data,
      status: (map['status'] ?? "Planning").toString(),
      isFavorite: map['isFavorite'] == true,
    );
  }
}
