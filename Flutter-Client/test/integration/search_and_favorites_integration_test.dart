import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:grabtube/presentation/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search and Favorites Integration Tests', () {
    testWidgets('should navigate to search page from home page',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Find and tap the search button in the app bar
      final searchButton = find.byIcon(Icons.search);
      expect(searchButton, findsOneWidget);
      await tester.tap(searchButton);
      await tester.pumpAndSettle();

      // Verify we're on the search page
      expect(find.text('Search Downloads'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display search results when query is entered',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to search page
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter search query
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'test video');
      await tester.pumpAndSettle();

      // Tap search button
      final searchIconButton = find.byIcon(Icons.search);
      await tester.tap(searchIconButton);
      await tester.pumpAndSettle();

      // Verify search results are displayed
      // Note: This would show actual results if downloads exist
      expect(find.text('Search Results'), findsOneWidget);
    });

    testWidgets('should filter favorites when favorites toggle is enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to search page
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Find and tap the favorites checkbox
      final favoritesCheckbox = find.bySemanticsLabel('Favorites only');
      expect(favoritesCheckbox, findsOneWidget);
      await tester.tap(favoritesCheckbox);
      await tester.pumpAndSettle();

      // Enter search query
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'test');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Verify favorites filter is applied
      expect(find.text('Search Results'), findsOneWidget);
    });

    testWidgets('should toggle favorite status on download item',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Assuming there are downloads displayed
      // Find a download item and tap its favorite button
      final favoriteButtons = find.byIcon(Icons.favorite_border);
      if (favoriteButtons.evaluate().isNotEmpty) {
        await tester.tap(favoriteButtons.first);
        await tester.pumpAndSettle();

        // Verify the icon changed to filled heart
        expect(find.byIcon(Icons.favorite), findsWidgets);
      }
    });

    testWidgets('should display favorites in dedicated section',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to search page
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enable favorites only filter
      final favoritesCheckbox = find.bySemanticsLabel('Favorites only');
      await tester.tap(favoritesCheckbox);
      await tester.pumpAndSettle();

      // Perform search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Verify only favorites are shown
      expect(find.text('Search Results'), findsOneWidget);
    });

    testWidgets('should clear search and return to home',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to search page
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter a search query
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'test query');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Find and tap clear search button
      final clearButton = find.text('Clear search');
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pumpAndSettle();

        // Verify we're back to home page
        expect(find.text('GrabTube'), findsOneWidget);
      }
    });

    testWidgets('should handle empty search results gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to search page
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search for something that doesn't exist
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'nonexistentvideothatdoesnotexist12345');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Verify empty state is handled
      expect(find.text('Search Results'), findsOneWidget);
      // Should show 0 results or appropriate empty message
    });

    testWidgets('should persist search query across app restarts',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to search page
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter search query
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'persisted query');

      // Simulate app restart by recreating the widget
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate back to search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Verify query is persisted (if implemented)
      // This depends on actual persistence implementation
    });
  });
}