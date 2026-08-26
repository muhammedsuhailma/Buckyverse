import 'dart:convert';
import 'package:http/http.dart' as http;

class TmdbService {
  static const String _apiKey = String.fromEnvironment('TMDB_API_KEY',
      defaultValue: '9d24d9e0232581bd465d732bca4690a6');
  static const _baseUrl = "https://api.themoviedb.org/3";
  final http.Client _client = http.Client();

  Map<int, String>? _movieGenres;
  Map<int, String>? _seriesGenres;
  Future<Map<int, String>>? _movieGenresFuture;
  Future<Map<int, String>>? _seriesGenresFuture;

  Future<http.Response?> _getWithRetry(String url, {int maxAttempts = 3}) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final response = await _client
            .get(Uri.parse(url), headers: {"Accept": "application/json"})
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          return response;
        } else if (response.statusCode == 429 ||
            response.statusCode >= 500 ||
            response.statusCode == 408) {
          if (attempt < maxAttempts - 1) {
            final delay = response.statusCode == 429
                ? Duration(milliseconds: 1000 * (attempt + 1))
                : Duration(milliseconds: 500 * (attempt + 1));
            await Future.delayed(delay);
            continue;
          }
        }
      } catch (_) {
        if (attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          continue;
        }
      }
    }
    return null;
  }

  Future<List<dynamic>> searchMovies(String query) async {
    final response = await _getWithRetry(
      "$_baseUrl/search/movie?api_key=$_apiKey&query=$query",
    );
    if (response != null && response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["results"] as List?) ?? [];
    }
    return [];
  }

  Future<List<dynamic>> searchSeries(String query) async {
    final response = await _getWithRetry(
      "$_baseUrl/search/tv?api_key=$_apiKey&query=$query",
    );
    if (response != null && response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["results"] as List?) ?? [];
    }
    return [];
  }

  Future<List<dynamic>> searchKdramas(String query) async {
    final response = await _getWithRetry(
      "$_baseUrl/search/tv?api_key=$_apiKey&query=$query&with_original_language=ko",
    );
    if (response != null && response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ((data["results"] as List?) ?? [])
          .where((tv) => tv["original_language"] == "ko")
          .toList();
    }
    return [];
  }

  Future<List<dynamic>> getTrendingMovies({int page = 1}) async {
    final response = await _getWithRetry(
      "$_baseUrl/trending/movie/week?api_key=$_apiKey&page=$page",
    );
    if (response != null && response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["results"] as List?) ?? [];
    }
    return [];
  }

  Future<List<dynamic>> getKdramas({int page = 1}) async {
    final response = await _getWithRetry(
      "$_baseUrl/discover/tv"
      "?api_key=$_apiKey"
      "&with_origin_country=KR"
      "&sort_by=popularity.desc"
      "&page=$page",
    );
    if (response != null && response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["results"] as List?) ?? [];
    }
    return [];
  }

  Future<List<dynamic>> getTrendingSeries({int page = 1}) async {
    final response = await _getWithRetry(
      "$_baseUrl/trending/tv/week?api_key=$_apiKey&page=$page",
    );
    if (response != null && response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["results"] as List?) ?? [];
    }
    return [];
  }

  Future<List<dynamic>> discoverMoviesByLanguage({
    required String languageCode,
    int page = 1,
  }) async {
    final response = await _getWithRetry(
      "$_baseUrl/discover/movie"
      "?api_key=$_apiKey"
      "&with_original_language=$languageCode"
      "&sort_by=popularity.desc"
      "&page=$page",
    );
    if (response != null && response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["results"] as List?) ?? [];
    }
    return [];
  }

  Future<List<dynamic>> discoverSeriesByLanguage({
    required String languageCode,
    int page = 1,
  }) async {
    final response = await _getWithRetry(
      "$_baseUrl/discover/tv"
      "?api_key=$_apiKey"
      "&with_original_language=$languageCode"
      "&sort_by=popularity.desc"
      "&page=$page",
    );
    if (response != null && response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["results"] as List?) ?? [];
    }
    return [];
  }

  Future<List<dynamic>> discoverKdramasByLanguage({
    required String languageCode,
    int page = 1,
  }) async {
    final countryFilter = languageCode == "ko" ? "&with_origin_country=KR" : "";
    final response = await _getWithRetry(
      "$_baseUrl/discover/tv"
      "?api_key=$_apiKey"
      "$countryFilter"
      "&with_original_language=$languageCode"
      "&sort_by=popularity.desc"
      "&page=$page",
    );
    if (response != null && response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["results"] as List?) ?? [];
    }
    return [];
  }

  Future<Map<int, String>> getMovieGenres() async {
    if (_movieGenres != null && _movieGenres!.isNotEmpty) {
      return _movieGenres!;
    }
    if (_movieGenresFuture != null) {
      return _movieGenresFuture!;
    }

    _movieGenresFuture = _fetchMovieGenres();
    return _movieGenresFuture!;
  }

  Future<Map<int, String>> _fetchMovieGenres() async {
    try {
      final response = await _getWithRetry(
        "$_baseUrl/genre/movie/list?api_key=$_apiKey",
      );
      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _movieGenres = {
          for (var g in (data["genres"] as List? ?? []))
            if (g["id"] is int && g["name"] is String)
              g["id"] as int: g["name"] as String,
        };
        return _movieGenres!;
      }
    } catch (_) {}
    _movieGenresFuture = null;
    return _movieGenres ?? {};
  }

  Future<Map<int, String>> getSeriesGenres() async {
    if (_seriesGenres != null && _seriesGenres!.isNotEmpty) {
      return _seriesGenres!;
    }
    if (_seriesGenresFuture != null) {
      return _seriesGenresFuture!;
    }

    _seriesGenresFuture = _fetchSeriesGenres();
    return _seriesGenresFuture!;
  }

  Future<Map<int, String>> _fetchSeriesGenres() async {
    try {
      final response = await _getWithRetry(
        "$_baseUrl/genre/tv/list?api_key=$_apiKey",
      );
      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _seriesGenres = {
          for (var g in (data["genres"] as List? ?? []))
            if (g["id"] is int && g["name"] is String)
              g["id"] as int: g["name"] as String,
        };
        return _seriesGenres!;
      }
    } catch (_) {}
    _seriesGenresFuture = null;
    return _seriesGenres ?? {};
  }

  String imageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    return "https://image.tmdb.org/t/p/w500$path";
  }
}
