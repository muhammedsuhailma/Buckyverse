import 'dart:convert';

import 'package:bucky_verse/models/anime_model.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class JikanService {
  static const String _baseUrl = 'https://api.jikan.moe/v4';
  final http.Client _client = http.Client();

  Future<List<AnimeModel>> getTopAnime({int page = 1}) async {
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await _client
            .get(Uri.parse('$_baseUrl/top/anime?page=$page'))
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final List data = (json['data'] as List?) ?? [];
          return data.map((anime) => AnimeModel.fromJson(anime)).toList();
        } else if (response.statusCode == 429 || response.statusCode >= 500) {
          // Rate limited or server error, wait and retry
          await Future.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
          continue;
        }

        break;
      } catch (e) {
        if (attempt < 2) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          continue;
        }
      }
    }
    return [];
  }

  Future<List<AnimeModel>> searchAnime(String query) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final response = await dio.get(
        "$_baseUrl/anime",
        queryParameters: {"q": query, "limit": 15},
      );

      final List data = (response.data["data"] as List?) ?? [];
      return data.map((e) => AnimeModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
