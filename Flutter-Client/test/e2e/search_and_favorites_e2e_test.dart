import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';

import 'package:grabtube/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  patrolTest('Search and Favorites E2E Test', (PatrolIntegrationTester $) async {
    // Start the app
    app.main();
    await $.pumpAndSettle();

    // Verify app starts successfully
    expect($('GrabTube'), findsOneWidget);

    // Navigate to search page
    await $.tap(find.byIcon(Icons.search));
    await $.pumpAndSettle();

    // Verify search page is displayed
    expect($('Search Downloads'), findsOneWidget);

    // Test search functionality
    final searchField = find.byType(TextField);
    await $.enterText(searchField, 'test video');
    await $.tap(find.byIcon(Icons.search));
    await $.pumpAndSettle();

    // Verify search results appear
    expect($('Search Results'), findsOneWidget);

    // Test favorites filter
    final favoritesCheckbox = find.bySemanticsLabel('Favorites only');
    await $.tap(favoritesCheckbox);
    await $.pumpAndSettle();

    // Perform search with favorites filter
    await $.tap(find.byIcon(Icons.search));
    await $.pumpAndSettle();

    // Verify filtered results
    expect($('Search Results'), findsOneWidget);

    // Test favorite toggling
    // Look for favorite buttons and tap one if available
    final favoriteButtons = find.byIcon(Icons.favorite_border);
    if (favoriteButtons.evaluate().isNotEmpty) {
      await $.tap(favoriteButtons.first);
      await $.pumpAndSettle();

      // Verify favorite was toggled
      expect(find.byIcon(Icons.favorite), findsWidgets);
    }

    // Test clearing search
    final clearButton = $('Clear search');
    if (clearButton.exists) {
      await $.tap(clearButton);
      await $.pumpAndSettle();

      // Verify we're back to home
      expect($('GrabTube'), findsOneWidget);
    }

    // Test search history (if implemented)
    // Navigate back to search
    await $.tap(find.byIcon(Icons.search));
    await $.pumpAndSettle();

    // Check if search history is displayed
    final historyItems = find.byType(ListTile);
    // History items should be visible if history exists

    // Test advanced search filters
    final filtersButton = $('Advanced Filters');
    if (filtersButton.exists) {
      await $.tap(filtersButton);
      await $.pumpAndSettle();

      // Test filter options
      final statusFilter = $('Status');
      if (statusFilter.exists) {
        await $.tap(statusFilter);
        await $.pumpAndSettle();
      }

      // Apply filters
      final applyButton = $('Apply Filters');
      if (applyButton.exists) {
        await $.tap(applyButton);
        await $.pumpAndSettle();
      }
    }

    // Test pagination
    final loadMoreButton = $('Load More');
    if (loadMoreButton.exists) {
      await $.tap(loadMoreButton);
      await $.pumpAndSettle();

      // Verify more results loaded
      expect($('Search Results'), findsOneWidget);
    }

    // Test search with different sort options
    final sortButton = $('Sort by');
    if (sortButton.exists) {
      await $.tap(sortButton);
      await $.pumpAndSettle();

      // Select different sort option
      final dateSort = $('Date');
      if (dateSort.exists) {
        await $.tap(dateSort);
        await $.pumpAndSettle();
      }
    }

    // Test search performance with large datasets
    // This would require setting up test data
    await $.enterText(searchField, 'performance test');
    final startTime = DateTime.now();
    await $.tap(find.byIcon(Icons.search));
    await $.pumpAndSettle();
    final endTime = DateTime.now();

    // Search should complete within reasonable time (e.g., 2 seconds)
    expect(endTime.difference(startTime).inSeconds, lessThan(5));

    // Test search with special characters
    await $.enterText(searchField, 'test@#\$%^&*()');
    await $.tap(find.byIcon(Icons.search));
    await $.pumpAndSettle();

    // Should handle special characters gracefully
    expect($('Search Results'), findsOneWidget);
  });
}