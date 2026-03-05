import 'package:flutter_test/flutter_test.dart';

import 'package:recipe_finder_meal_plan/main.dart';

void main() {
  testWidgets('Home page shows primary actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Recipe Finder'), findsOneWidget);
    expect(find.text('Go to Search'), findsOneWidget);
    expect(find.text('Add Ingredients'), findsOneWidget);
  });

  testWidgets('Go to Search navigates to recipe search page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Go to Search'));
    await tester.pumpAndSettle();

    expect(find.text('Search recipes'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets('Add Ingredients navigates to ingredients page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Add Ingredients'));
    await tester.pumpAndSettle();

    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Add ingredient'), findsOneWidget);
  });
}
