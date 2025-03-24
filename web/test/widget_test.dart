import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/main.dart';
import 'package:link_shortener/screens/home_screen.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/services/url_service.dart';
import 'mocks/app_config.generate.mocks.dart';
import 'mocks/auth_service.generate.mocks.dart';
import 'mocks/url_service.generate.mocks.dart';

void main() {
  late MockAppConfig config;
  late AuthService authService;
  late UrlService urlService;
  
  setUp(() {
    config = MockAppConfig();
    authService = MockAuthService();
    urlService = MockUrlService();
  });
  
  tearDown(() {
    urlService.dispose();
    authService.dispose();
  });

  testWidgets('App loads with basic components', (tester) async {
    await tester.pumpWidget(LinkShortenerApp(
      config: config,
      authService: authService,
      urlService: urlService,
    ));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Link Shortener'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });
}
