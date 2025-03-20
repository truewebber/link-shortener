import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../lib/services/api_service.dart';
import '../lib/config/app_config.dart';

@GenerateMocks([http.Client])
class MockApiService extends Mock implements ApiService {}

class TestAppConfig extends AppConfig {
  TestAppConfig() : super(
    apiBaseUrl: 'http://test-api.example.com',
    environment: 'test',
  );
}

class TestWidgetWrapper extends StatelessWidget {
  final Widget child;
  final AppConfig config;

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
      final found = any(finder);
      if (found) {
        return;
      }
    }
    throw Exception('Timeout waiting for ${finder.description}');
  }
}
