import 'dart:convert';

import 'package:http/http.dart' as http;

import 'recipe_summary.dart';
import 'spoonacular_config.dart';

class SpoonacularApi {
  SpoonacularApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://api.spoonacular.com';

  Future<List<RecipeSummary>> searchRecipes(
    String query, {
    int number = 20,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return [];
    }

    final uri = Uri.parse('$_baseUrl/recipes/complexSearch').replace(
      queryParameters: <String, String>{
        'query': trimmedQuery,
        'number': number.toString(),
        'apiKey': spoonacularApiKey,
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Spoonacular request failed (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final results = decoded['results'] as List<dynamic>? ?? <dynamic>[];

    return results
        .whereType<Map<String, dynamic>>()
        .map(RecipeSummary.fromJson)
        .toList();
  }
}
