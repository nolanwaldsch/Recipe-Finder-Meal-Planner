import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipe_finder_meal_plan/spoonacular/spoonacular_api.dart';

http.Response _jsonResponse(Object body, [int status = 200]) {
  return http.Response(jsonEncode(body), status);
}

void main() {
  group('SpoonacularApi.searchRecipes', () {
    group('empty inputs', () {
      test('returns empty list when query and ingredients are both empty',
          () async {
        var requestMade = false;
        final api = SpoonacularApi(
          client: MockClient((_) async {
            requestMade = true;
            return _jsonResponse({});
          }),
        );

        final results = await api.searchRecipes('');

        expect(results, isEmpty);
        expect(requestMade, isFalse);
        api.close();
      });

      test('returns empty list when query is whitespace and no ingredients',
          () async {
        var requestMade = false;
        final api = SpoonacularApi(
          client: MockClient((_) async {
            requestMade = true;
            return _jsonResponse({});
          }),
        );

        final results = await api.searchRecipes('   ');

        expect(results, isEmpty);
        expect(requestMade, isFalse);
        api.close();
      });
    });

    group('complexSearch (query only)', () {
      test('calls complexSearch endpoint when only a query is provided',
          () async {
        Uri? capturedUri;
        final api = SpoonacularApi(
          client: MockClient((request) async {
            capturedUri = request.url;
            return _jsonResponse({
              'results': [
                {'id': 1, 'title': 'Pasta Carbonara', 'image': ''},
              ],
            });
          }),
        );

        final results = await api.searchRecipes('pasta');

        expect(capturedUri?.path, contains('complexSearch'));
        expect(capturedUri?.queryParameters['query'], 'pasta');
        expect(results.length, 1);
        expect(results.first.title, 'Pasta Carbonara');
        api.close();
      });

      test('trims the query before sending', () async {
        Uri? capturedUri;
        final api = SpoonacularApi(
          client: MockClient((request) async {
            capturedUri = request.url;
            return _jsonResponse({'results': []});
          }),
        );

        await api.searchRecipes('  soup  ');

        expect(capturedUri?.queryParameters['query'], 'soup');
        api.close();
      });

      test('returns empty list when results array is empty', () async {
        final api = SpoonacularApi(
          client: MockClient(
            (_) async => _jsonResponse({'results': []}),
          ),
        );

        final results = await api.searchRecipes('xyz_no_results');

        expect(results, isEmpty);
        api.close();
      });

      test('passes the number parameter', () async {
        Uri? capturedUri;
        final api = SpoonacularApi(
          client: MockClient((request) async {
            capturedUri = request.url;
            return _jsonResponse({'results': []});
          }),
        );

        await api.searchRecipes('chicken', number: 5);

        expect(capturedUri?.queryParameters['number'], '5');
        api.close();
      });
    });

    group('findByIngredients (ingredients provided)', () {
      test('calls findByIngredients endpoint when ingredients are provided',
          () async {
        Uri? capturedUri;
        final api = SpoonacularApi(
          client: MockClient((request) async {
            capturedUri = request.url;
            return _jsonResponse([
              {'id': 2, 'title': 'Tomato Soup', 'image': ''},
            ]);
          }),
        );

        final results = await api.searchRecipes(
          '',
          includeIngredients: ['tomato', 'onion'],
        );

        expect(capturedUri?.path, contains('findByIngredients'));
        expect(capturedUri?.queryParameters['ingredients'], contains('tomato'));
        expect(results.length, 1);
        expect(results.first.title, 'Tomato Soup');
        api.close();
      });

      test('filters results by query when both query and ingredients given',
          () async {
        final api = SpoonacularApi(
          client: MockClient(
            (_) async => _jsonResponse([
              {'id': 1, 'title': 'Tomato Soup', 'image': ''},
              {'id': 2, 'title': 'Pasta Bake', 'image': ''},
            ]),
          ),
        );

        final results = await api.searchRecipes(
          'tomato',
          includeIngredients: ['tomato'],
        );

        expect(results.length, 1);
        expect(results.first.title, 'Tomato Soup');
        api.close();
      });

      test('query filter is case-insensitive', () async {
        final api = SpoonacularApi(
          client: MockClient(
            (_) async => _jsonResponse([
              {'id': 1, 'title': 'Chicken Stir Fry', 'image': ''},
              {'id': 2, 'title': 'Beef Burger', 'image': ''},
            ]),
          ),
        );

        final results = await api.searchRecipes(
          'CHICKEN',
          includeIngredients: ['chicken'],
        );

        expect(results.length, 1);
        expect(results.first.title, 'Chicken Stir Fry');
        api.close();
      });

      test('ignores empty and whitespace-only ingredient strings', () async {
        Uri? capturedUri;
        final api = SpoonacularApi(
          client: MockClient((request) async {
            capturedUri = request.url;
            return _jsonResponse({'results': []});
          }),
        );

        await api.searchRecipes('pasta', includeIngredients: ['', '   ']);

        expect(capturedUri?.path, contains('complexSearch'));
        api.close();
      });

      test('trims whitespace from each ingredient', () async {
        Uri? capturedUri;
        final api = SpoonacularApi(
          client: MockClient((request) async {
            capturedUri = request.url;
            return _jsonResponse([]);
          }),
        );

        await api.searchRecipes('', includeIngredients: ['  egg  ', ' flour']);

        final ingredientsParam = capturedUri?.queryParameters['ingredients'];
        expect(ingredientsParam, contains('egg'));
        expect(ingredientsParam, contains('flour'));
        expect(ingredientsParam, isNot(contains('  ')));
        api.close();
      });
    });

    group('HTTP error handling', () {
      test('throws with authentication message on 401', () async {
        final api = SpoonacularApi(
          client: MockClient(
            (_) async => http.Response('Unauthorized', 401),
          ),
        );

        await expectLater(
          api.searchRecipes('pasta'),
          throwsA(
            predicate<dynamic>(
              (e) => e.toString().contains('authentication failed'),
            ),
          ),
        );
        api.close();
      });

      test('throws with authentication message on 403', () async {
        final api = SpoonacularApi(
          client: MockClient((_) async => http.Response('Forbidden', 403)),
        );

        await expectLater(
          api.searchRecipes('pasta'),
          throwsA(
            predicate<dynamic>(
              (e) => e.toString().contains('authentication failed'),
            ),
          ),
        );
        api.close();
      });

      test('throws with quota message on 402', () async {
        final api = SpoonacularApi(
          client: MockClient(
            (_) async => http.Response('Payment Required', 402),
          ),
        );

        await expectLater(
          api.searchRecipes('pasta'),
          throwsA(
            predicate<dynamic>(
              (e) => e.toString().contains('quota exceeded'),
            ),
          ),
        );
        api.close();
      });

      test('throws with quota message on 429', () async {
        final api = SpoonacularApi(
          client: MockClient(
            (_) async => http.Response('Too Many Requests', 429),
          ),
        );

        await expectLater(
          api.searchRecipes('pasta'),
          throwsA(
            predicate<dynamic>(
              (e) => e.toString().contains('quota exceeded'),
            ),
          ),
        );
        api.close();
      });

      test('throws with server unavailable message on 500', () async {
        final api = SpoonacularApi(
          client: MockClient(
            (_) async => http.Response('Internal Server Error', 500),
          ),
        );

        await expectLater(
          api.searchRecipes('pasta'),
          throwsA(
            predicate<dynamic>(
              (e) => e.toString().contains('temporarily unavailable'),
            ),
          ),
        );
        api.close();
      });

      test('throws with generic message for other non-200 codes', () async {
        final api = SpoonacularApi(
          client: MockClient((_) async => http.Response('Not Found', 404)),
        );

        await expectLater(
          api.searchRecipes('pasta'),
          throwsA(
            predicate<dynamic>((e) => e.toString().contains('404')),
          ),
        );
        api.close();
      });

      test('throws with network error message on SocketException', () async {
        final api = SpoonacularApi(
          client: MockClient(
            (_) async => throw const SocketException('No route to host'),
          ),
        );

        await expectLater(
          api.searchRecipes('pasta'),
          throwsA(
            predicate<dynamic>(
              (e) => e.toString().contains('Network error'),
            ),
          ),
        );
        api.close();
      });

      test('throws with connection message on ClientException', () async {
        final api = SpoonacularApi(
          client: MockClient(
            (_) async =>
                throw http.ClientException('Connection refused'),
          ),
        );

        await expectLater(
          api.searchRecipes('pasta'),
          throwsA(
            predicate<dynamic>(
              (e) => e.toString().contains('Unable to reach Spoonacular'),
            ),
          ),
        );
        api.close();
      });
    });
  });
}
