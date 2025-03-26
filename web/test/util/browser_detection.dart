import 'package:flutter_test/flutter_test.dart';

// Utility functions for browser detection in tests

/// Checks if the current environment is a browser with JS capabilities
bool get isBrowserEnvironment {
  try {
    return const bool.fromEnvironment('dart.library.js');
  } catch (e) {
    return false;
  }
}

/// Wrapper for test skipping with a standard message
void skipIfNotBrowser(WidgetTester tester) {
  if (!isBrowserEnvironment) {
    markTestSkipped(
      'This test requires JavaScript interop and should run only in a browser environment',
    );
    return;
  }
}
