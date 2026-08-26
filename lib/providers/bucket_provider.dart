import 'package:flutter/material.dart';
import '../models/bucket_item.dart';
import '../services/firestore_service.dart';
import 'package:flutter/foundation.dart';

class BucketProvider extends ChangeNotifier {
  FirestoreService? _firestoreInstance;
  FirestoreService get _firestore => _firestoreInstance ??= FirestoreService();

  BucketProvider({FirestoreService? firestore}) : _firestoreInstance = firestore;

  final List<BucketItem> _bucketItems = [];

  bool get isSearching => _searchText.isNotEmpty;

  String _selectedFilter = "All";
  String _selectedCategory = "All";
  String _searchText = "";

  String get selectedFilter => _selectedFilter;
  String get selectedCategory => _selectedCategory;

  List<BucketItem> get bucketItems => _bucketItems;

  bool _itemMatchesCategory(BucketItem item, String category) {
    if (category == "All" || category == "All Universes") return true;
    final rawType =
        (item.data["type"] ?? item.data["category"] ?? "")
            .toString()
            .toUpperCase();
    switch (category) {
      case "Anime":
        return rawType.contains("ANIME");
      case "Movies":
        return rawType.contains("MOVIE");
      case "Series":
        return rawType.contains("SERIES");
      case "K-Drama":
        return rawType.contains("DRAMA");
      default:
        return true;
    }
  }

  bool _itemMatchesSearch(BucketItem item, String search) {
    if (search.isEmpty) return true;
    return (item.data["title"] ?? "")
        .toString()
        .toLowerCase()
        .contains(search);
  }

  Iterable<BucketItem> get _contextualItems {
    return _bucketItems.where((item) {
      if (!_itemMatchesCategory(item, _selectedCategory)) return false;
      if (!_itemMatchesSearch(item, _searchText)) return false;
      return true;
    });
  }

  List<BucketItem> get filteredItems {
    return _bucketItems.where((item) {
      // 1. Status filter
      if (_selectedFilter == "Favorites") {
        if (!item.isFavorite) return false;
      } else if (_selectedFilter != "All") {
        if (item.status != _selectedFilter) return false;
      }

      // 2. Category filter
      if (!_itemMatchesCategory(item, _selectedCategory)) return false;

      // 3. Search filter
      if (!_itemMatchesSearch(item, _searchText)) return false;

      return true;
    }).toList();
  }

  // Contextual statistics (scoped to selected category & search query)
  int get totalCount => _contextualItems.length;

  int get planningCount =>
      _contextualItems.where((e) => e.status == "Planning").length;

  int get watchingCount =>
      _contextualItems.where((e) => e.status == "Watching").length;

  int get completedCount =>
      _contextualItems
          .where((e) => e.status == "Completed" || e.status == "Done")
          .length;

  int get favoritesCount =>
      _contextualItems.where((e) => e.isFavorite).length;

  // Global statistics (all items in bucket)
  int get globalTotalCount => _bucketItems.length;

  int get globalPlanningCount =>
      _bucketItems.where((e) => e.status == "Planning").length;

  int get globalWatchingCount =>
      _bucketItems.where((e) => e.status == "Watching").length;

  int get globalCompletedCount =>
      _bucketItems
          .where((e) => e.status == "Completed" || e.status == "Done")
          .length;

  int get globalFavoritesCount =>
      _bucketItems.where((e) => e.isFavorite).length;

  Null get searchController => null;

  bool isFavorite(String id) {
    final item = getItem(id);
    return item?.isFavorite ?? false;
  }

  bool isAdded(String id) {
    return _bucketItems.any((item) => item.id == id);
  }

  BucketItem? getItem(String id) {
    try {
      return _bucketItems.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  void changeSearch(String value) {
    _searchText = value.toLowerCase();
    notifyListeners();
  }

  void changeFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void changeCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Load bucket from Firestore
 Future<void> loadBucket() async {
  debugPrint("Loading bucket from Firestore...");

  _bucketItems.clear();

  final items = await _firestore.loadBucket();

  debugPrint("Loaded ${items.length} items");

  _bucketItems.addAll(items);

  notifyListeners();
}

  /// Add item
  Future<void> addItem(BucketItem item) async {
    final exists = _bucketItems.any((e) => e.id == item.id);

    if (exists) return;

    _bucketItems.add(item);
    notifyListeners();

    await _firestore.addBucketItem(item);
  }

  /// Remove item
  Future<void> removeItem(String id) async {
    _bucketItems.removeWhere((item) => item.id == id);
    notifyListeners();

    await _firestore.removeBucketItem(id);
  }

  /// Toggle favorite
  Future<void> toggleFavorite(String id) async {
    final index = _bucketItems.indexWhere((item) => item.id == id);

    if (index == -1) return;

    _bucketItems[index].isFavorite = !_bucketItems[index].isFavorite;

    notifyListeners();

    await _firestore.updateBucketItem(_bucketItems[index]);
  }

  /// Change status
  Future<void> changeStatus(String id, String status) async {
    final index = _bucketItems.indexWhere((item) => item.id == id);

    if (index == -1) return;

    _bucketItems[index].status = status;

    notifyListeners();

    await _firestore.updateBucketItem(_bucketItems[index]);
  }

  /// Update both values
  Future<void> updateItem(String id, {String? status, bool? isFavorite}) async {
    final index = _bucketItems.indexWhere((item) => item.id == id);

    if (index == -1) return;

    _bucketItems[index] = _bucketItems[index].copyWith(
      status: status,
      isFavorite: isFavorite,
    );

    notifyListeners();

    await _firestore.updateBucketItem(_bucketItems[index]);
  }
}
