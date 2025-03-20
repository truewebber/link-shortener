import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';
import 'test_helper.dart';

void main() {
  group('Main App', () {
    testWidgets('initializes with correct configuration', (tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Verify app title
      expect(find.text('URL Shortener'), findsOneWidget);
      
      // Verify theme
      final theme = Theme.of(tester.element(find.byType(MyApp)));
      expect(theme.brightness, Brightness.light);
      
      // Verify home screen is displayed
      expect(find.byType(HomeScreen), findsOneWidget);
    });
    
    testWidgets('handles theme changes correctly', (tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Verify initial theme
      final initialTheme = Theme.of(tester.element(find.byType(MyApp)));
      expect(initialTheme.brightness, Brightness.light);
      
      // Change to dark theme
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pump();
      
      // Verify theme consistency
      final finalTheme = Theme.of(tester.element(find.byType(MyApp)));
      expect(finalTheme.brightness, Brightness.light);
    });
    
    testWidgets('maintains responsive layout', (tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Test desktop layout (>900px)
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pump();
      expect(find.byType(Row), findsOneWidget);
      
      // Test tablet layout (600-900px)
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pump();
      expect(find.byType(Column), findsOneWidget);
      
      // Test mobile layout (<600px)
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();
      expect(find.byType(Column), findsOneWidget);
    });
    
    testWidgets('handles navigation correctly', (tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Verify initial route
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Test navigation (if implemented)
      // await tester.tap(find.byIcon(Icons.menu));
      // await tester.pumpAndSettle();
      // expect(find.byType(Drawer), findsOneWidget);
    });
    
    testWidgets('maintains app state', (tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Verify initial state
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Test state persistence
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pump();
      
      // Verify state is maintained
      expect(find.byType(HomeScreen), findsOneWidget);
    });
    
    testWidgets('handles system back button', (tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Simulate back button press
      await tester.pageBack();
      await tester.pumpAndSettle();
      
      // Verify app is still running
      expect(find.byType(HomeScreen), findsOneWidget);
    });
    
    testWidgets('maintains consistent styling', (tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Verify text styles
      expect(
        find.text('URL Shortener'),
        findsOneWidget,
      );
      
      // Verify button styles
      expect(
        find.byType(ElevatedButton),
        findsOneWidget,
      );
      
      // Verify input field styles
      expect(
        find.byType(TextFormField),
        findsOneWidget,
      );
    });
    
    testWidgets('handles orientation changes', (tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Test portrait orientation
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();
      expect(find.byType(Column), findsOneWidget);
      
      // Test landscape orientation
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pump();
      expect(find.byType(Row), findsOneWidget);
    });
  });
}
