import 'dart:collection';

class IngredientsRepository {
  IngredientsRepository._();

  static final IngredientsRepository instance = IngredientsRepository._();

  final LinkedHashSet<String> _ingredients = LinkedHashSet<String>();

  List<String> get ingredients => _ingredients.toList(growable: false);

  bool add(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return false;
    }

    return _ingredients.add(normalized);
  }

  bool remove(String value) {
    return _ingredients.remove(value);
  }

  void clear() {
    _ingredients.clear();
  }
}
