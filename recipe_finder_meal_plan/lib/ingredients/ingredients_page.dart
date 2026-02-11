import 'package:flutter/material.dart';

import 'ingredients_repository.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key});

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _ingredients = <String>[];

  @override
  void initState() {
    super.initState();
    _ingredients = List<String>.of(IngredientsRepository.instance.ingredients);
  }

  void _addIngredient() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      return;
    }
    setState(() {
      IngredientsRepository.instance.add(value);
      _ingredients = List<String>.of(
        IngredientsRepository.instance.ingredients,
      );
      _controller.clear();
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      IngredientsRepository.instance.removeAt(index);
      _ingredients = List<String>.of(
        IngredientsRepository.instance.ingredients,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: const Text('Ingredients'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addIngredient(),
                      decoration: const InputDecoration(
                        labelText: 'Add ingredient',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addIngredient,
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_ingredients.isEmpty)
                const Text('Add ingredients one by one to build your list.'),
              if (_ingredients.isNotEmpty)
                Expanded(
                  child: ListView.separated(
                    itemCount: _ingredients.length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final ingredient = _ingredients[index];
                      return ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(ingredient),
                        trailing: IconButton(
                          onPressed: () => _removeIngredient(index),
                          icon: const Icon(Icons.close),
                          tooltip: 'Remove',
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
