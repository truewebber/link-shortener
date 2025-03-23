import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:link_shortener/config/app_config_provider.dart';
import 'package:link_shortener/services/api_service.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/services/url_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mock_app_config.dart';

@GenerateMocks([http.Client])
class MockApiService extends Mock implements ApiService {}

// Use the MockAppConfig instead of extending AppConfig
typedef TestAppConfig = MockAppConfig;

class TestWidgetWrapper extends StatefulWidget {

  /// Creates a new test widget wrapper
  const TestWidgetWrapper({
    super.key,
    required this.child,
    required this.config,
    this.authService,
    this.urlService,
  });
  /// The child widget to wrap
  final Widget child;
  
  /// The mock configuration to use
  final MockAppConfig config;

  /// The mock auth service to use
  final AuthService? authService;
  
  /// The mock URL service to use
  final UrlService? urlService;

  @override
  State<TestWidgetWrapper> createState() => _TestWidgetWrapperState();
      
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty<MockAppConfig>('config', config))
    ..add(DiagnosticsProperty<AuthService?>('authService', authService))
    ..add(DiagnosticsProperty<UrlService?>('urlService', urlService));
  }
}

class _TestWidgetWrapperState extends State<TestWidgetWrapper> {
  @override
  Widget build(BuildContext context) => AppConfigProvider(
        config: widget.config,
        child: MaterialApp(
          home: Scaffold(
            body: widget.child,
          ),
        ),
      );

  @override
  void dispose() {
    // Ensure all resources are cleaned up properly
    final authService = widget.authService;
    if (authService != null) {
      // Flush any pending operations in the auth service
      Future.microtask(() {
        try {
          authService.dispose();
        } catch (e) {
          if (kDebugMode) {
            print('Error disposing auth service: $e');
          }
        }
      });
    }
    
    super.dispose();
  }
}

extension WidgetTesterExtension on WidgetTester {
  Future<void> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    var timerDone = false;
    final completer = Completer<void>();
    
    // Create a timer that will complete the completer after the timeout
    final timer = Timer(timeout, () {
      timerDone = true;
      if (!completer.isCompleted) {
        completer.completeError(Exception('Timeout waiting for ${finder.describeMatch}'));
      }
    });
    
    try {
      while (!timerDone) {
        await pump(const Duration(milliseconds: 100));
        try {
          expect(finder, findsOneWidget);
          completer.complete();
          break;
        } catch (_) {
          // Keep trying until timeout
        }
      }
      
      return completer.future;
    } finally {
      // Always cancel the timer to prevent leaks
      timer.cancel();
    }
  }
}
