import 'package:flutter/material.dart';
import 'package:bucky_verse/services/anilist_service.dart';
import 'package:bucky_verse/services/tmdb_service.dart';

class ApiProvider extends ChangeNotifier {
final AniListService _service = AniListService();  
final TmdbService _tmdb = TmdbService();

  List<Map<String, dynamic>> _anime = [];
  List<Map<String, dynamic>> _movies = [];
  List<Map<String, dynamic>> _series = [];
  List<Map<String, dynamic>> _kdramas = [];

  List<Map<String, dynamic>> _searchAnime = [];
  List<Map<String, dynamic>> _searchMovies = [];
  List<Map<String, dynamic>> _searchSeries = [];
  List<Map<String, dynamic>> _searchKdramas = [];

  List<Map<String, dynamic>> get anime => _anime;
  List<Map<String, dynamic>> get movies => _movies;
  List<Map<String, dynamic>> get series => _series;
  List<Map<String, dynamic>> get kdramas => _kdramas;
  List<Map<String, dynamic>> get exploreItems => [
    ..._anime,
    ..._movies,
    ..._series,
    ..._kdramas,
  ];
  List<Map<String, dynamic>> get newReleases {
    final items = [...exploreItems];

    items.sort((a, b) {
      final ay = int.tryParse(a["year"]?.toString() ?? "0") ?? 0;
      final by = int.tryParse(b["year"]?.toString() ?? "0") ?? 0;
      return by.compareTo(ay); 
    });

    return items;
  }

  List<Map<String, dynamic>> get searchAnime => _searchAnime;
  List<Map<String, dynamic>> get searchMovies => _searchMovies;
  List<Map<String, dynamic>> get searchSeries => _searchSeries;
  List<Map<String, dynamic>> get searchKdramas => _searchKdramas;
  List<Map<String, dynamic>> get searchItems => [
    ..._searchAnime,
    ..._searchMovies,
    ..._searchSeries,
    ..._searchKdramas,
  ];

  final Map<String, List<Map<String, dynamic>>> _languageCache = {};
  bool _isLanguageLoading = false;

  bool get isLanguageLoading => _isLanguageLoading;
  Map<String, List<Map<String, dynamic>>> get languageCache => _languageCache;

  bool _isAnimeLoading = false;
  bool _isMoviesLoading = false;
  bool _isSeriesLoading = false;
  bool _isKdramasLoading = false;
  bool _isSearching = false;

  bool get isAnimeLoading => _isAnimeLoading;
  bool get isMoviesLoading => _isMoviesLoading;
  bool get isSeriesLoading => _isSeriesLoading;
  bool get isKdramasLoading => _isKdramasLoading;
  bool get isSearching => _isSearching;
  bool get isLoading =>
      _isSearching ||
      _isLanguageLoading ||
      _isAnimeLoading ||
      _isMoviesLoading ||
      _isSeriesLoading ||
      _isKdramasLoading;

   String _mapLanguage(String? code) {
    switch (code) {
      case "hi":
        return "Hindi";
      case "ml":
        return "Malayalam";
      case "ta":
        return "Tamil";
      case "te":
        return "Telugu";
      case "en":
        return "English";
      case "ko":
        return "Korean";
      case "ja":
        return "Japanese";
      default:
        if (code == null || code.isEmpty) return "English";
        return "${code[0].toUpperCase()}${code.substring(1)}";
    }
  }

  Map<String, dynamic> buildTmdbItem({
    required Map<String, dynamic> item,
    required Map<int, String> genres,
    required String category,
    required String type,
  }) {
    final genreIds = (item["genre_ids"] as List?) ?? [];
    final rawLang = item["original_language"]?.toString();
    return {
      "id": (item["id"] ?? "").toString(),
      "title": (item["title"] ?? item["name"] ?? "").toString(),
      "image": _tmdb.imageUrl(item["poster_path"]?.toString()),
      "rating": ((item["vote_average"] ?? 0) as num).toStringAsFixed(1),
      "year": (item["release_date"] ?? item["first_air_date"] ?? "")
          .toString()
          .split("-")
          .first,
      "category": category,
      "type": type,
      "language": _mapLanguage(rawLang),
      "description": (item["overview"] ?? "").toString(),
      "genres": genreIds
          .map((id) => genres[id] ?? "")
          .where((g) => g.isNotEmpty)
          .join(", "),
      "duration": "",
      "similar": [],
    };
  }

  // ==================== ANIME ====================

  Future<void> loadTopAnime() async {
    if (_isAnimeLoading) return;
    _isAnimeLoading = true;
    notifyListeners();

    List apiAnime = [];

    for (int page = 1; page <= 3; page++) {
      try {
        final result = await _service.getTopAnime(page: page);
        apiAnime.addAll(result);
      } catch (e) {
        debugPrint("Failed to load anime page $page: $e");
      }
    }

    if (apiAnime.isNotEmpty || _anime.isEmpty) {
      _anime = apiAnime.map((anime) {
        return {
          "id": anime.id.toString(),
          "title": anime.title,
          "image": anime.image,
          "rating": anime.rating.toStringAsFixed(1),
          "year": anime.year > 0 ? anime.year.toString() : "",
          "category": "Anime",
          "type": "TV ANIME",
          "language": "Japanese",
          "description": anime.synopsis,
          "genres": (anime.genres as List).join(", "),
          "duration": "",
          "similar": [],
        };
      }).toList();
    }

    _isAnimeLoading = false;
    notifyListeners();
  }

  // ==================== MOVIES ====================

  Future<void> loadTrendingMovies() async {
    if (_isMoviesLoading) return;
    _isMoviesLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _tmdb.getTrendingMovies(page: 1),
        _tmdb.getTrendingMovies(page: 2),
        _tmdb.getTrendingMovies(page: 3),
        _tmdb.getMovieGenres(),
      ]);

      final page1 = results[0] as List<dynamic>;
      final page2 = results[1] as List<dynamic>;
      final page3 = results[2] as List<dynamic>;
      final genres = results[3] as Map<int, String>;

      final movies = [...page1, ...page2, ...page3];

      debugPrint("Movie API returned ${movies.length} items");

      if (movies.isNotEmpty || _movies.isEmpty) {
        _movies = movies
            .map<Map<String, dynamic>>(
              (movie) => buildTmdbItem(
                item: movie,
                genres: genres,
                category: "Movies",
                type: "MOVIE",
              ),
            )
            .take(50)
            .toList();
      }
    } catch (e) {
      debugPrint("Failed to load movies: $e");
      if (_movies.isEmpty) _movies = [];
    } finally {
      _isMoviesLoading = false;
      notifyListeners();
    }

    debugPrint("Movies Loaded: ${_movies.length}");
  }

  // ==================== SERIES ====================

  Future<void> loadTrendingSeries() async {
    if (_isSeriesLoading) return;
    _isSeriesLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _tmdb.getTrendingSeries(page: 1),
        _tmdb.getTrendingSeries(page: 2),
        _tmdb.getTrendingSeries(page: 3),
        _tmdb.getSeriesGenres(),
      ]);

      final page1 = results[0] as List<dynamic>;
      final page2 = results[1] as List<dynamic>;
      final page3 = results[2] as List<dynamic>;
      final genres = results[3] as Map<int, String>;

      final series = [...page1, ...page2, ...page3];

      debugPrint("Series API returned ${series.length} items");

      if (series.isNotEmpty || _series.isEmpty) {
        _series = series
            .map<Map<String, dynamic>>(
              (item) => buildTmdbItem(
                item: item,
                genres: genres,
                category: "Series",
                type: "TV SERIES",
              ),
            )
            .take(50)
            .toList();
      }
    } catch (e) {
      debugPrint("Failed to load series: $e");
      if (_series.isEmpty) _series = [];
    } finally {
      _isSeriesLoading = false;
      notifyListeners();
    }

    debugPrint("Series Loaded: ${_series.length}");
  }
  // ==================== K-DRAMAS ====================

  Future<void> loadKdramas() async {
    if (_isKdramasLoading) return;
    _isKdramasLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _tmdb.getKdramas(page: 1),
        _tmdb.getKdramas(page: 2),
        _tmdb.getKdramas(page: 3),
        _tmdb.getSeriesGenres(),
      ]);

      final page1 = results[0] as List<dynamic>;
      final page2 = results[1] as List<dynamic>;
      final page3 = results[2] as List<dynamic>;
      final genres = results[3] as Map<int, String>;

      final dramas = [...page1, ...page2, ...page3];

      debugPrint("K-Drama API returned ${dramas.length} items");

      if (dramas.isNotEmpty || _kdramas.isEmpty) {
        _kdramas = dramas
            .map<Map<String, dynamic>>((drama) {
              final genreIds = (drama["genre_ids"] as List?) ?? [];

              return {
                "id": (drama["id"] ?? "").toString(),
                "title": (drama["name"] ?? "").toString(),
                "image": _tmdb.imageUrl(drama["poster_path"]?.toString()),
                "rating": ((drama["vote_average"] ?? 0) as num).toStringAsFixed(
                  1,
                ),
                "year": (drama["first_air_date"] ?? "")
                    .toString()
                    .split("-")
                    .first,
                "category": "K-Drama",
                "type": "TV SERIES",
                "language": _mapLanguage(
                  drama["original_language"]?.toString() ?? "ko",
                ),
                "description": (drama["overview"] ?? "").toString(),
                "genres": genreIds
                    .map((id) => genres[id] ?? "")
                    .where((g) => g.isNotEmpty)
                    .join(", "),
                "duration": "",
                "similar": [],
              };
            })
            .take(50)
            .toList();
      }
    } catch (e) {
      debugPrint("Failed to load K-Drama: $e");
      if (_kdramas.isEmpty) _kdramas = [];
    } finally {
      _isKdramasLoading = false;
      notifyListeners();
    }

    debugPrint("K-Dramas Loaded: ${_kdramas.length}");
  }
  // ==================== DEDICATED LANGUAGE DATASETS & CACHING ====================

  List<Map<String, dynamic>>? getCachedDataset(String category, String languageCode) {
    return _languageCache["$category-$languageCode"];
  }

  Future<List<Map<String, dynamic>>> fetchLanguageCategoryDataset({
    required String category,
    required String languageCode,
  }) async {
    final cacheKey = "$category-$languageCode";

    if (_languageCache.containsKey(cacheKey) &&
        _languageCache[cacheKey] != null &&
        _languageCache[cacheKey]!.isNotEmpty) {
      return _languageCache[cacheKey]!;
    }

    _isLanguageLoading = true;
    notifyListeners();

    List<Map<String, dynamic>> items = [];

    try {
      if (category == "Anime") {
        if (_anime.isEmpty) {
          await loadTopAnime();
        }
        items = List.from(_anime);
      } else if (category == "Movies") {
        final results = await Future.wait([
          _tmdb.discoverMoviesByLanguage(languageCode: languageCode, page: 1),
          _tmdb.discoverMoviesByLanguage(languageCode: languageCode, page: 2),
          _tmdb.discoverMoviesByLanguage(languageCode: languageCode, page: 3),
          _tmdb.getMovieGenres(),
        ]);

        final page1 = results[0] as List<dynamic>;
        final page2 = results[1] as List<dynamic>;
        final page3 = results[2] as List<dynamic>;
        final genres = results[3] as Map<int, String>;
        final rawMovies = [...page1, ...page2, ...page3];

        items = rawMovies
            .map<Map<String, dynamic>>(
              (movie) => buildTmdbItem(
                item: movie,
                genres: genres,
                category: "Movies",
                type: "MOVIE",
              ),
            )
            .take(50)
            .toList();
      } else if (category == "Series") {
        final results = await Future.wait([
          _tmdb.discoverSeriesByLanguage(languageCode: languageCode, page: 1),
          _tmdb.discoverSeriesByLanguage(languageCode: languageCode, page: 2),
          _tmdb.discoverSeriesByLanguage(languageCode: languageCode, page: 3),
          _tmdb.getSeriesGenres(),
        ]);

        final page1 = results[0] as List<dynamic>;
        final page2 = results[1] as List<dynamic>;
        final page3 = results[2] as List<dynamic>;
        final genres = results[3] as Map<int, String>;
        final rawSeries = [...page1, ...page2, ...page3];

        items = rawSeries
            .map<Map<String, dynamic>>(
              (series) => buildTmdbItem(
                item: series,
                genres: genres,
                category: "Series",
                type: "TV SERIES",
              ),
            )
            .take(50)
            .toList();
      } else if (category == "K-Drama") {
        final results = await Future.wait([
          _tmdb.discoverKdramasByLanguage(languageCode: languageCode, page: 1),
          _tmdb.discoverKdramasByLanguage(languageCode: languageCode, page: 2),
          _tmdb.discoverKdramasByLanguage(languageCode: languageCode, page: 3),
          _tmdb.getSeriesGenres(),
        ]);

        final page1 = results[0] as List<dynamic>;
        final page2 = results[1] as List<dynamic>;
        final page3 = results[2] as List<dynamic>;
        final genres = results[3] as Map<int, String>;
        final rawDramas = [...page1, ...page2, ...page3];

        items = rawDramas
            .map<Map<String, dynamic>>((drama) {
              final genreIds = (drama["genre_ids"] as List?) ?? [];
              return {
                "id": (drama["id"] ?? "").toString(),
                "title": (drama["name"] ?? "").toString(),
                "image": _tmdb.imageUrl(drama["poster_path"]?.toString()),
                "rating": ((drama["vote_average"] ?? 0) as num).toStringAsFixed(1),
                "year": (drama["first_air_date"] ?? "").toString().split("-").first,
                "category": "K-Drama",
                "type": "TV SERIES",
                "language": _mapLanguage(
                  drama["original_language"]?.toString() ?? languageCode,
                ),
                "description": (drama["overview"] ?? "").toString(),
                "genres": genreIds
                    .map((id) => genres[id] ?? "")
                    .where((g) => g.isNotEmpty)
                    .join(", "),
                "duration": "",
                "similar": [],
              };
            })
            .take(50)
            .toList();
      } else {
        // "All Universes" with specific language
        if (languageCode == "ja") {
          if (_anime.isEmpty) {
            await loadTopAnime();
          }
          final results = await Future.wait([
            _tmdb.discoverMoviesByLanguage(languageCode: "ja", page: 1),
            _tmdb.discoverSeriesByLanguage(languageCode: "ja", page: 1),
            _tmdb.getMovieGenres(),
            _tmdb.getSeriesGenres(),
          ]);
          final jaMovies = (results[0] as List<dynamic>).map((m) => buildTmdbItem(
            item: m,
            genres: results[2] as Map<int, String>,
            category: "Movies",
            type: "MOVIE",
          ));
          final jaSeries = (results[1] as List<dynamic>).map((s) => buildTmdbItem(
            item: s,
            genres: results[3] as Map<int, String>,
            category: "Series",
            type: "TV SERIES",
          ));

          items = [
            ..._anime.take(25),
            ...jaMovies.take(15),
            ...jaSeries.take(10),
          ];
        } else {
          final results = await Future.wait([
            _tmdb.discoverMoviesByLanguage(languageCode: languageCode, page: 1),
            _tmdb.discoverMoviesByLanguage(languageCode: languageCode, page: 2),
            _tmdb.discoverSeriesByLanguage(languageCode: languageCode, page: 1),
            _tmdb.discoverSeriesByLanguage(languageCode: languageCode, page: 2),
            _tmdb.getMovieGenres(),
            _tmdb.getSeriesGenres(),
          ]);

          final m1 = results[0] as List<dynamic>;
          final m2 = results[1] as List<dynamic>;
          final s1 = results[2] as List<dynamic>;
          final s2 = results[3] as List<dynamic>;
          final movieGenres = results[4] as Map<int, String>;
          final seriesGenres = results[5] as Map<int, String>;

          final movieItems = [...m1, ...m2].map((m) => buildTmdbItem(
            item: m,
            genres: movieGenres,
            category: "Movies",
            type: "MOVIE",
          )).toList();

          final seriesItems = [...s1, ...s2].map((s) => buildTmdbItem(
            item: s,
            genres: seriesGenres,
            category: "Series",
            type: "TV SERIES",
          )).toList();

          final combined = <Map<String, dynamic>>[];
          final maxLen = movieItems.length > seriesItems.length ? movieItems.length : seriesItems.length;
          for (int i = 0; i < maxLen; i++) {
            if (i < movieItems.length) combined.add(movieItems[i]);
            if (i < seriesItems.length) combined.add(seriesItems[i]);
          }
          items = combined.take(50).toList();
        }
      }

      if (items.isNotEmpty) {
        _languageCache[cacheKey] = items;
      }
    } catch (e) {
      debugPrint("Failed to fetch language dataset for $cacheKey: $e");
    } finally {
      _isLanguageLoading = false;
      notifyListeners();
    }

    return items;
  }

  // ==================== LOAD EVERYTHING ====================

  Future<void> loadAll() async {
    await Future.wait([
      loadTopAnime(),
      loadTrendingMovies(),
      loadTrendingSeries(),
      loadKdramas(),
    ]);
  }

  // ==================== SEARCH ====================

  Future<void> searchAll(String query) async {
    if (query.trim().isEmpty) {
      _searchAnime.clear();
      _searchMovies.clear();
      _searchSeries.clear();
      _searchKdramas.clear();

      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.searchAnime(query),
        _tmdb.searchMovies(query),
        _tmdb.searchSeries(query),
        _tmdb.searchKdramas(query),
        _tmdb.getMovieGenres(),
        _tmdb.getSeriesGenres(),
      ]);

      final animeResults = results[0] as List;
      final movieResults = results[1] as List;
      final seriesResults = results[2] as List;
      final kdramaResults = results[3] as List;
      final movieGenres = results[4] as Map<int, String>;
      final seriesGenres = results[5] as Map<int, String>;

      // Anime
      _searchAnime = animeResults.map<Map<String, dynamic>>((anime) {
        return {
          "id": anime.id.toString(),
          "title": anime.title,
          "image": anime.image,
          "rating": anime.rating.toStringAsFixed(1),
          "year": anime.year > 0 ? anime.year.toString() : "",
          "category": "Anime",
          "type": "TV ANIME",
          "language": "Japanese",
          "description": anime.synopsis,
          "genres": (anime.genres as List).join(", "),
          "duration": "",
          "similar": [],
        };
      }).toList();

      // Movies — buildTmdbItem already includes "language" via original_language
      _searchMovies = movieResults
          .map<Map<String, dynamic>>(
            (movie) => buildTmdbItem(
              item: movie,
              genres: movieGenres,
              category: "Movies",
              type: "MOVIE",
            ),
          )
          .toList();

      // Series — buildTmdbItem already includes "language" via original_language
      _searchSeries = seriesResults
          .map<Map<String, dynamic>>(
            (series) => buildTmdbItem(
              item: series,
              genres: seriesGenres,
              category: "Series",
              type: "TV SERIES",
            ),
          )
          .toList();

      // K-Drama
      _searchKdramas = kdramaResults.map<Map<String, dynamic>>((drama) {
        final genreIds = (drama["genre_ids"] as List?) ?? [];
        return {
          "id": (drama["id"] ?? "").toString(),
          "title": (drama["name"] ?? "").toString(),
          "image": _tmdb.imageUrl(drama["poster_path"]?.toString()),
          "rating": ((drama["vote_average"] ?? 0) as num).toStringAsFixed(1),
          "year": (drama["first_air_date"] ?? "").toString().split("-").first,
          "category": "K-Drama",
          "type": "TV SERIES",
          "language": _mapLanguage(
            drama["original_language"]?.toString() ?? "ko",
          ),
          "description": (drama["overview"] ?? "").toString(),
          "genres": genreIds
              .map((id) => seriesGenres[id] ?? "")
              .where((g) => g.isNotEmpty)
              .join(", "),
          "duration": "",
          "similar": [],
        };
      }).toList();
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchAnime.clear();
    _searchMovies.clear();
    _searchSeries.clear();
    _searchKdramas.clear();
    _isSearching = false;
    notifyListeners();
  }

  Future<void> searchAnimeOnly(String query) async {
    if (query.trim().isEmpty) {
      _searchAnime.clear();
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final results = await _service.searchAnime(query);

      _searchAnime = results.map((anime) {
        return {
          "id": anime.id.toString(),
          "title": anime.title,
          "image": anime.image,
          "rating": anime.rating.toStringAsFixed(1),
          "year": anime.year > 0 ? anime.year.toString() : "",
          "category": "Anime",
          "type": "TV ANIME",
          "language": "Japanese",
          "description": anime.synopsis,
          "genres": anime.genres.join(", "),
          "duration": "",
          "similar": [],
        };
      }).toList();
    } catch (e) {
      debugPrint("Search anime error: $e");
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }
}
