import 'package:flutter/material.dart';
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

/// Gets device pixel ratio from the tester
/// Uses the non-deprecated view property instead of window
double getDevicePixelRatio(WidgetTester tester) => tester.view.devicePixelRatio;

/// Gets the physical size from the tester
/// Uses the non-deprecated view property instead of window
Size getPhysicalSize(WidgetTester tester) => tester.view.physicalSize;

/// Sets the test window size in a non-deprecated way
void setDisplaySize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
}

/// Clears the physical size test value (for use in tearDown)
/// Replacement for tester.binding.window.clearPhysicalSizeTestValue
void clearPhysicalSizeTestValue(WidgetTester tester) {
  tester.view.resetPhysicalSize();
}

/// Clears the device pixel ratio test value (for use in tearDown)
/// Replacement for tester.binding.window.clearDevicePixelRatioTestValue
void clearDevicePixelRatioTestValue(WidgetTester tester) {
  tester.view.resetDevicePixelRatio();
}
