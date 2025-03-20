import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:link_shortener/config/app_config_provider.dart';
import 'package:link_shortener/services/api_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mock_app_config.dart';

@GenerateMocks([http.Client])
class MockApiService extends Mock implements ApiService {}

// Use the MockAppConfig instead of extending AppConfig
typedef TestAppConfig = MockAppConfig;

class TestWidgetWrapper extends StatelessWidget {

  /// Creates a new test widget wrapper
  const TestWidgetWrapper({
    super.key,
    required this.child,
    required this.config,
  });
  /// The child widget to wrap
  final Widget child;
  
  /// The mock configuration to use
  final MockAppConfig config;

  @override
  Widget build(BuildContext context) => AppConfigProvider(
        config: config,
        child: MaterialApp(
          home: Scaffold(
            body: child,
          ),
        ),
      );
      
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<MockAppConfig>('config', config));
  }
}

extension WidgetTesterExtension on WidgetTester {
  Future<void> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    var timerDone = false;
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
    throw Exception('Timeout waiting for ${finder.describeMatch}');
  }
}
