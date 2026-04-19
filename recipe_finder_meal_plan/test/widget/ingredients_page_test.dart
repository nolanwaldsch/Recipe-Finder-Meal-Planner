import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_finder_meal_plan/ingredients/ingredients_page.dart';
import 'package:recipe_finder_meal_plan/ingredients/ingredients_repository.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  final repo = IngredientsRepository.instance;

  setUp(repo.clear);
  tearDown(repo.clear);

  testWidgets('shows app bar title', (tester) async {
    await tester.pumpWidget(_wrap(const IngredientsPage()));

    expect(find.text('Ingredients'), findsOneWidget);
  });

  testWidgets('shows Add ingredient text field and button', (tester) async {
    await tester.pumpWidget(_wrap(const IngredientsPage()));

    expect(find.widgetWithText(TextField, 'Add ingredient'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Add'), findsOneWidget);
  });

  testWidgets('shows empty-state hint when ingredient list is empty',
      (tester) async {
    await tester.pumpWidget(_wrap(const IngredientsPage()));

    expect(
      find.text('Add ingredients one by one to build your list.'),
      findsOneWidget,
    );
  });

  testWidgets('adds ingredient and shows it in the list', (tester) async {
    await tester.pumpWidget(_wrap(const IngredientsPage()));

    await tester.enterText(find.byType(TextField), 'tomato');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pump();

    expect(find.text('tomato'), findsOneWidget);
    expect(
      find.text('Add ingredients one by one to build your list.'),
      findsNothing,
    );
  });

  testWidgets('clears text field after adding an ingredient', (tester) async {
    await tester.pumpWidget(_wrap(const IngredientsPage()));

    await tester.enterText(find.byType(TextField), 'garlic');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pump();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, '');
  });

  testWidgets('does nothing when Add is tapped with empty field', (tester) async {
    await tester.pumpWidget(_wrap(const IngredientsPage()));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pump();

    expect(
      find.text('Add ingredients one by one to build your list.'),
      findsOneWidget,
    );
  });

  testWidgets('does not add duplicate ingredient', (tester) async {
    await tester.pumpWidget(_wrap(const IngredientsPage()));

    await tester.enterText(find.byType(TextField), 'onion');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'onion');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pump();

    expect(find.text('onion'), findsOneWidget);
  });

  testWidgets('removes an ingredient when close icon is tapped', (tester) async {
    await tester.pumpWidget(_wrap(const IngredientsPage()));

    await tester.enterText(find.byType(TextField), 'pepper');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pump();

    expect(find.text('pepper'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove'));
    await tester.pump();

    expect(find.text('pepper'), findsNothing);
    expect(
      find.text('Add ingredients one by one to build your list.'),
      findsOneWidget,
    );
  });

  testWidgets('shows multiple ingredients as list tiles', (tester) async {
    await tester.pumpWidget(_wrap(const IngredientsPage()));

    for (final ingredient in ['egg', 'flour', 'milk']) {
      await tester.enterText(find.byType(TextField), ingredient);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pump();
    }

    expect(find.text('egg'), findsOneWidget);
    expect(find.text('flour'), findsOneWidget);
    expect(find.text('milk'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(3));
  });

  testWidgets('submitting text field via keyboard adds ingredient',
      (tester) async {
    await tester.pumpWidget(_wrap(const IngredientsPage()));

    await tester.enterText(find.byType(TextField), 'basil');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('basil'), findsOneWidget);
  });
}
