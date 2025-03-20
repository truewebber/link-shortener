import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';
import 'package:link_shortener/config/app_config_provider.dart';
import 'package:link_shortener/services/api_service.dart';
import 'mocks/mock_app_config.dart';

@GenerateMocks([http.Client])
class MockApiService extends Mock implements ApiService {}

// Use the MockAppConfig instead of extending AppConfig
typedef TestAppConfig = MockAppConfig;

class TestWidgetWrapper extends StatelessWidget {
  final Widget child;
  final MockAppConfig config;

  const TestWidgetWrapper({
    super.key,
    required this.child,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return AppConfigProvider(
      config: config,
      child: MaterialApp(
        home: child,
      ),
    );
  }
}

extension WidgetTesterExtension on WidgetTester {
  Future<void> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    bool timerDone = false;
    Timer(timeout, () => timerDone = true);
    while (!timerDone) {
      await pump(const Duration(milliseconds: 100));
      try {
        expect(finder, findsOneWidget);
        return;
      } catch (_) {
        // Keep trying until timeout
      }
    }
    throw Exception('Timeout waiting for ${finder.description}');
  }
}
