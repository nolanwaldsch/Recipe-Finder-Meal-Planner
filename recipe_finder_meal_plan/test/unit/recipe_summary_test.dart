import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_finder_meal_plan/spoonacular/recipe_summary.dart';

void main() {
  group('RecipeSummary.fromJson', () {
    test('parses all fields correctly', () {
      final recipe = RecipeSummary.fromJson({
        'id': 123,
        'title': 'Spaghetti Carbonara',
        'image': 'https://example.com/pasta.jpg',
      });

      expect(recipe.id, 123);
      expect(recipe.title, 'Spaghetti Carbonara');
      expect(recipe.imageUrl, 'https://example.com/pasta.jpg');
    });

    test('defaults title to Untitled when key is absent', () {
      final recipe = RecipeSummary.fromJson({
        'id': 1,
        'image': 'https://example.com/img.jpg',
      });

      expect(recipe.title, 'Untitled');
    });

    test('defaults title to Untitled when value is null', () {
      final recipe = RecipeSummary.fromJson({'id': 1, 'title': null});

      expect(recipe.title, 'Untitled');
    });

    test('defaults imageUrl to empty string when key is absent', () {
      final recipe = RecipeSummary.fromJson({'id': 2, 'title': 'Soup'});

      expect(recipe.imageUrl, '');
    });

    test('defaults imageUrl to empty string when value is null', () {
      final recipe = RecipeSummary.fromJson({
        'id': 2,
        'title': 'Soup',
        'image': null,
      });

      expect(recipe.imageUrl, '');
    });

    test('handles both title and image absent', () {
      final recipe = RecipeSummary.fromJson({'id': 99});

      expect(recipe.title, 'Untitled');
      expect(recipe.imageUrl, '');
    });

    test('assigns id correctly for large values', () {
      final recipe = RecipeSummary.fromJson({'id': 999999, 'title': 'Big'});

      expect(recipe.id, 999999);
    });
  });
}
