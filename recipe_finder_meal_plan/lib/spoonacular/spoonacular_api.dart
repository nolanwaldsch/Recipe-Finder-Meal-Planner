import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'recipe_summary.dart';
import 'spoonacular_config.dart';

class SpoonacularApi {
  SpoonacularApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://api.spoonacular.com';
  static const Duration _requestTimeout = Duration(seconds: 12);

  void close() {
    _client.close();
  }

  Future<List<RecipeSummary>> searchRecipes(
    String query, {
    List<String> includeIngredients = const <String>[],
    int number = 20,
  }) async {
    final trimmedQuery = query.trim();
    final trimmedIngredients = includeIngredients
        .map((ingredient) => ingredient.trim())
        .where((ingredient) => ingredient.isNotEmpty)
        .toList();

    if (trimmedQuery.isEmpty && trimmedIngredients.isEmpty) {
      return [];
    }

    if (trimmedIngredients.isNotEmpty) {
      final uri = Uri.parse('$_baseUrl/recipes/findByIngredients').replace(
        queryParameters: <String, String>{
          'ingredients': trimmedIngredients.join(','),
          'number': number.toString(),
          'apiKey': spoonacularApiKey,
        },
      );

      final response = await _get(uri);

      final decoded = jsonDecode(response.body) as List<dynamic>;
      final results = decoded
          .whereType<Map<String, dynamic>>()
          .map(RecipeSummary.fromJson)
          .toList();

      if (trimmedQuery.isEmpty) {
        return results;
      }

      final loweredQuery = trimmedQuery.toLowerCase();
      return results
          .where((recipe) => recipe.title.toLowerCase().contains(loweredQuery))
          .toList();
    }

    final queryParameters = <String, String>{
      'number': number.toString(),
      'apiKey': spoonacularApiKey,
    };

    if (trimmedQuery.isNotEmpty) {
      queryParameters['query'] = trimmedQuery;
    }

    final uri = Uri.parse(
      '$_baseUrl/recipes/complexSearch',
    ).replace(queryParameters: queryParameters);

    final response = await _get(uri);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final results = decoded['results'] as List<dynamic>? ?? <dynamic>[];

    return results
        .whereType<Map<String, dynamic>>()
        .map(RecipeSummary.fromJson)
        .toList();
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_requestTimeout);
      if (response.statusCode == 200) {
        return response;
      }

      throw Exception(_statusCodeMessage(response.statusCode));
    } on SocketException {
      throw Exception('Network error. Check your connection and try again.');
    } on http.ClientException {
      throw Exception('Unable to reach Spoonacular right now.');
    } on FormatException {
      throw Exception('Received an unexpected response from Spoonacular.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  String _statusCodeMessage(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return 'Spoonacular authentication failed. Check API key configuration.';
    }

    if (statusCode == 402 || statusCode == 429) {
      return 'Spoonacular API quota exceeded. Please try again later.';
    }

    if (statusCode >= 500) {
      return 'Spoonacular is temporarily unavailable. Please retry shortly.';
    }

    return 'Spoonacular request failed ($statusCode).';
  }
}
