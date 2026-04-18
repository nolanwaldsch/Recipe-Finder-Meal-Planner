import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_finder_meal_plan/ingredients/ingredients_repository.dart';

void main() {
  final repo = IngredientsRepository.instance;

  setUp(repo.clear);
  tearDown(repo.clear);

  group('IngredientsRepository.add', () {
    test('adds a new ingredient and returns true', () {
      expect(repo.add('tomato'), isTrue);
      expect(repo.ingredients, contains('tomato'));
    });

    test('trims leading and trailing whitespace', () {
      repo.add('  garlic  ');
      expect(repo.ingredients, contains('garlic'));
      expect(repo.ingredients, isNot(contains('  garlic  ')));
    });

    test('returns false for an empty string', () {
      expect(repo.add(''), isFalse);
      expect(repo.ingredients, isEmpty);
    });

    test('returns false for a whitespace-only string', () {
      expect(repo.add('   '), isFalse);
      expect(repo.ingredients, isEmpty);
    });

    test('returns false when adding a duplicate ingredient', () {
      repo.add('onion');
      expect(repo.add('onion'), isFalse);
      expect(repo.ingredients.length, 1);
    });

    test('stores multiple unique ingredients', () {
      repo.add('egg');
      repo.add('flour');
      repo.add('milk');
      expect(repo.ingredients.length, 3);
    });

    test('preserves insertion order', () {
      repo.add('a');
      repo.add('b');
      repo.add('c');
      expect(repo.ingredients, orderedEquals(['a', 'b', 'c']));
    });
  });

  group('IngredientsRepository.remove', () {
    test('removes an existing ingredient and returns true', () {
      repo.add('basil');
      expect(repo.remove('basil'), isTrue);
      expect(repo.ingredients, isNot(contains('basil')));
    });

    test('returns false when ingredient does not exist', () {
      expect(repo.remove('nonexistent'), isFalse);
    });

    test('only removes the specified ingredient', () {
      repo.add('salt');
      repo.add('pepper');
      repo.remove('salt');
      expect(repo.ingredients, contains('pepper'));
      expect(repo.ingredients, isNot(contains('salt')));
    });
  });

  group('IngredientsRepository.clear', () {
    test('removes all ingredients', () {
      repo.add('a');
      repo.add('b');
      repo.clear();
      expect(repo.ingredients, isEmpty);
    });

    test('is safe to call when already empty', () {
      expect(() => repo.clear(), returnsNormally);
    });
  });

  group('IngredientsRepository.ingredients getter', () {
    test('returns an empty list when nothing has been added', () {
      expect(repo.ingredients, isEmpty);
    });

    test('returns a non-growable list', () {
      repo.add('milk');
      final list = repo.ingredients;
      expect(() => (list as dynamic).add('extra'), throwsUnsupportedError);
    });

    test('returned list does not reflect subsequent mutations to the repo', () {
      repo.add('egg');
      final snapshot = repo.ingredients;
      repo.add('butter');
      expect(snapshot.length, 1);
    });
  });
}
