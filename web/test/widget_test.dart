// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/main.dart';
import 'package:link_shortener/screens/home_screen.dart';
import 'mocks/mock_app_config.dart';
import 'mocks/mock_auth_service.dart';

void main() {
  testWidgets('App loads with basic components', (tester) async {
    // Create test configuration and auth service
    final config = MockAppConfig();
    final authService = MockAuthService();
    
    // Build our app and trigger a frame
    await tester.pumpWidget(LinkShortenerApp(
      config: config,
      authService: authService,
    ));

    // Verify that our app has loaded the HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);
    
    // Verify that the app title is present
    expect(find.text('Link Shortener'), findsOneWidget);
    
    // Verify that the main form is there
    expect(find.byType(TextFormField), findsOneWidget);
  });
}
