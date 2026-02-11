class IngredientsRepository {
  IngredientsRepository._();

  static final IngredientsRepository instance = IngredientsRepository._();

  final List<String> _ingredients = <String>[];

  List<String> get ingredients => List<String>.unmodifiable(_ingredients);

  void add(String value) {
    _ingredients.add(value);
  }

  void removeAt(int index) {
    if (index < 0 || index >= _ingredients.length) {
      return;
    }
    _ingredients.removeAt(index);
  }

  void clear() {
    _ingredients.clear();
  }
}
