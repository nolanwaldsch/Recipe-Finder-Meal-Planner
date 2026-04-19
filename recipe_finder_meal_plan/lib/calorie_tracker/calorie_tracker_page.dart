import 'package:flutter/material.dart';

enum MealType { breakfast, lunch, dinner, snack }

class MealEntry {
  MealEntry({required this.food, required this.calories});

  final String food;
  final int calories;
}

class CalorieTrackerPage extends StatefulWidget {
  const CalorieTrackerPage({super.key});

  @override
  State<CalorieTrackerPage> createState() => _CalorieTrackerPageState();
}

class _CalorieTrackerPageState extends State<CalorieTrackerPage> {
  final Map<MealType, TextEditingController> _foodControllers =
      <MealType, TextEditingController>{
        MealType.breakfast: TextEditingController(),
        MealType.lunch: TextEditingController(),
        MealType.dinner: TextEditingController(),
        MealType.snack: TextEditingController(),
      };

  final Map<MealType, TextEditingController> _calorieControllers =
      <MealType, TextEditingController>{
        MealType.breakfast: TextEditingController(),
        MealType.lunch: TextEditingController(),
        MealType.dinner: TextEditingController(),
        MealType.snack: TextEditingController(),
      };

  final Map<MealType, List<MealEntry>> _mealEntries =
      <MealType, List<MealEntry>>{
        MealType.breakfast: <MealEntry>[],
        MealType.lunch: <MealEntry>[],
        MealType.dinner: <MealEntry>[],
        MealType.snack: <MealEntry>[],
      };

  int get _totalCalories {
    return _mealEntries.values
        .expand((entries) => entries)
        .fold<int>(0, (sum, entry) => sum + entry.calories);
  }

  int _mealTotal(MealType meal) {
    return _mealEntries[meal]!.fold<int>(
      0,
      (sum, entry) => sum + entry.calories,
    );
  }

  void _addMealEntry(MealType meal) {
    final food = _foodControllers[meal]!.text.trim();
    final caloriesText = _calorieControllers[meal]!.text.trim();
    final calories = int.tryParse(caloriesText);

    if (food.isEmpty || calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enter a food name and a valid calorie amount for ${_mealLabel(meal).toLowerCase()}.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _mealEntries[meal]!.add(MealEntry(food: food, calories: calories));
      _foodControllers[meal]!.clear();
      _calorieControllers[meal]!.clear();
    });
  }

  @override
  void dispose() {
    for (final controller in _foodControllers.values) {
      controller.dispose();
    }
    for (final controller in _calorieControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _mealLabel(MealType meal) {
    switch (meal) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  Widget _buildMealCard(MealType meal) {
    final entries = _mealEntries[meal]!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _mealLabel(meal),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _foodControllers[meal],
              decoration: const InputDecoration(
                labelText: 'What did you eat?',
                hintText: 'Enter food item',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _calorieControllers[meal],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Calories',
                      hintText: 'Enter calories',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => _addMealEntry(meal),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text(
                  'Items (${_mealTotal(meal)} cal)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                subtitle: Text(
                  entries.isEmpty
                      ? 'No items added yet.'
                      : '${entries.length} item(s) added',
                ),
                children: entries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(item.food),
                    subtitle: Text('${item.calories} cal'),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          entries.removeAt(index);
                        });
                      },
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Remove item',
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Calorie Tracker'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    _buildMealCard(MealType.breakfast),
                    _buildMealCard(MealType.lunch),
                    _buildMealCard(MealType.dinner),
                    _buildMealCard(MealType.snack),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Daily calories: $_totalCalories'),
                      ),
                    );
                  },
                  child: Text('Total Calories: $_totalCalories'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
