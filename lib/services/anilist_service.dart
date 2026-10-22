import 'package:bucky_verse/models/anime_model.dart';
import 'package:dio/dio.dart';

class AniListService {
  static const String _baseUrl = 'https://graphql.anilist.co';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<List<AnimeModel>> getTopAnime({int page = 1}) async {
    const query = '''
      query (\$page: Int) {
        Page(page: \$page, perPage: 20) {
          media(type: ANIME, sort: POPULARITY_DESC) {
            id
            title {
              romaji
              english
              native
            }
            coverImage {
              large
              extraLarge
            }
            averageScore
            description(asHtml: false)
            startDate {
              year
            }
            genres
          }
        }
      }
    ''';

    try {
      final response = await _dio.post(
        _baseUrl,
        data: {
          'query': query,
          'variables': {'page': page},
        },
      );

      final List data = response.data['data']?['Page']?['media'] as List? ?? [];

      return data
          .map(
            (anime) =>
                AnimeModel.fromJson(Map<String, dynamic>.from(anime as Map)),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        'Failed to load popular anime: ${e.response?.statusCode ?? e.message}',
      );
    } catch (e) {
      throw Exception('Failed to process popular anime: $e');
    }
  }

  Future<List<AnimeModel>> searchAnime(String queryText) async {
    if (queryText.trim().isEmpty) return [];

    const query = '''
      query (\$search: String) {
        Page(page: 1, perPage: 15) {
          media(
            type: ANIME
            search: \$search
            sort: SEARCH_MATCH
          ) {
            id
            title {
              romaji
              english
              native
            }
            coverImage {
              large
              extraLarge
            }
            averageScore
            description(asHtml: false)
            startDate {
              year
            }
            genres
          }
        }
      }
    ''';

    try {
      final response = await _dio.post(
        _baseUrl,
        data: {
          'query': query,
          'variables': {'search': queryText.trim()},
        },
      );

      final List data = response.data['data']?['Page']?['media'] as List? ?? [];

      return data
          .map(
            (anime) =>
                AnimeModel.fromJson(Map<String, dynamic>.from(anime as Map)),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        'Failed to search anime: ${e.response?.statusCode ?? e.message}',
      );
    } catch (e) {
      throw Exception('Failed to process anime search: $e');
    }
  }

  void dispose() {
    _dio.close();
  }
}
