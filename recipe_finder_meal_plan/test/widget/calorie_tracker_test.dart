import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_finder_meal_plan/calorie_tracker/calorie_tracker_page.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  testWidgets('shows Calorie Tracker app bar', (tester) async {
    await tester.pumpWidget(_wrap(const CalorieTrackerPage()));

    expect(find.text('Calorie Tracker'), findsOneWidget);
  });

  testWidgets('shows all four meal sections', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_wrap(const CalorieTrackerPage()));

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('Snack'), findsOneWidget);
  });

  testWidgets('shows total calories button starting at zero', (tester) async {
    await tester.pumpWidget(_wrap(const CalorieTrackerPage()));

    expect(find.text('Total Calories: 0'), findsOneWidget);
  });

  testWidgets('shows empty state in each meal expansion tile', (tester) async {
    await tester.pumpWidget(_wrap(const CalorieTrackerPage()));

    expect(find.text('No items added yet.'), findsNWidgets(4));
  });

  testWidgets('adds a meal entry and updates the expansion tile subtitle',
      (tester) async {
    await tester.pumpWidget(_wrap(const CalorieTrackerPage()));

    final foodFields = find.widgetWithText(TextField, 'What did you eat?');
    final calorieFields = find.widgetWithText(TextField, 'Calories');
    final addButtons = find.widgetWithText(FilledButton, 'Add');

    await tester.enterText(foodFields.first, 'Oatmeal');
    await tester.enterText(calorieFields.first, '300');
    await tester.tap(addButtons.first);
    await tester.pump();

    expect(find.text('1 item(s) added'), findsOneWidget);
  });

  testWidgets('adds a meal entry and updates the total calories button',
      (tester) async {
    await tester.pumpWidget(_wrap(const CalorieTrackerPage()));

    final foodFields = find.widgetWithText(TextField, 'What did you eat?');
    final calorieFields = find.widgetWithText(TextField, 'Calories');
    final addButtons = find.widgetWithText(FilledButton, 'Add');

    await tester.enterText(foodFields.first, 'Eggs');
    await tester.enterText(calorieFields.first, '150');
    await tester.tap(addButtons.first);
    await tester.pump();

    expect(find.text('Total Calories: 150'), findsOneWidget);
  });

  testWidgets('accumulates calories from multiple entries in the same meal',
      (tester) async {
    await tester.pumpWidget(_wrap(const CalorieTrackerPage()));

    final foodField = find.widgetWithText(TextField, 'What did you eat?').first;
    final calorieField = find.widgetWithText(TextField, 'Calories').first;
    final addButton = find.widgetWithText(FilledButton, 'Add').first;

    await tester.enterText(foodField, 'Oatmeal');
    await tester.enterText(calorieField, '300');
    await tester.tap(addButton);
    await tester.pump();

    await tester.enterText(foodField, 'Orange Juice');
    await tester.enterText(calorieField, '110');
    await tester.tap(addButton);
    await tester.pump();

    expect(find.text('Total Calories: 410'), findsOneWidget);
    expect(find.text('2 item(s) added'), findsOneWidget);
  });

  testWidgets('clears input fields after adding an entry', (tester) async {
    await tester.pumpWidget(_wrap(const CalorieTrackerPage()));

    final foodField = find.widgetWithText(TextField, 'What did you eat?').first;
    final calorieField = find.widgetWithText(TextField, 'Calories').first;

    await tester.enterText(foodField, 'Toast');
    await tester.enterText(calorieField, '90');
    await tester.tap(find.widgetWithText(FilledButton, 'Add').first);
    await tester.pump();

    expect(tester.widget<TextField>(foodField).controller?.text, '');
    expect(tester.widget<TextField>(calorieField).controller?.text, '');
  });

  testWidgets('shows snackbar when food field is empty on Add', (tester) async {
    await tester.pumpWidget(_wrap(const CalorieTrackerPage()));

    await tester.enterText(
      find.widgetWithText(TextField, 'Calories').first,
      '200',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add').first);
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('breakfast'), findsOneWidget);
  });

  testWidgets('shows snackbar when calories field is empty on Add',
      (tester) async {
    await tester.pumpWidget(_wrap(const CalorieTrackerPage()));

    await tester.enterText(
      find.widgetWithText(TextField, 'What did you eat?').first,
      'Apple',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add').first);
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('shows snackbar when calories is zero', (tester) async {
    await tester.pumpWidget(_wrap(const CalorieTrackerPage()));

    await tester.enterText(
      find.widgetWithText(TextField, 'What did you eat?').first,
      'Water',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Calories').first,
      '0',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add').first);
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('shows snackbar when calories is non-numeric', (tester) async {
    await tester.pumpWidget(_wrap(const CalorieTrackerPage()));

    await tester.enterText(
      find.widgetWithText(TextField, 'What did you eat?').first,
      'Steak',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Calories').first,
      'many',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add').first);
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('tapping total calories button shows snackbar with total',
      (tester) async {
    await tester.pumpWidget(_wrap(const CalorieTrackerPage()));

    await tester.tap(find.widgetWithText(FilledButton, 'Total Calories: 0'));
    await tester.pump();

    expect(find.textContaining('Daily calories: 0'), findsOneWidget);
  });

  testWidgets('removes a meal entry when delete icon is tapped', (tester) async {
    await tester.pumpWidget(_wrap(const CalorieTrackerPage()));

    // Add an entry to breakfast
    await tester.enterText(
      find.widgetWithText(TextField, 'What did you eat?').first,
      'Banana',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Calories').first,
      '89',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add').first);
    await tester.pump();

    // Expand the Breakfast tile to reveal the entry
    await tester.tap(find.textContaining('Items (89 cal)'));
    await tester.pumpAndSettle();

    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Total Calories: 89'), findsOneWidget);

    // Delete the entry
    await tester.tap(find.byTooltip('Remove item'));
    await tester.pump();

    expect(find.text('Banana'), findsNothing);
    expect(find.text('Total Calories: 0'), findsOneWidget);
  });
}
