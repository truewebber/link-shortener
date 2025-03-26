import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../util/browser_detection.dart';

void main() {
  group('Platform Features Tests', () {
    // Setup to capture the tester for use in tearDown
    late WidgetTester sharedTester;

    // Using proper tearDown to reset view properties
    tearDown(() {
      clearPhysicalSizeTestValue(sharedTester);
      clearDevicePixelRatioTestValue(sharedTester);
    });

    testWidgets('platform features can be accessed with non-deprecated APIs',
        (tester) async {
      // Save tester for tearDown
      sharedTester = tester;

      skipIfNotBrowser(tester);

      // Access platform features using recommended APIs
      final platformDispatcher = tester.platformDispatcher;
      final view = tester.view;

      // Print platform information for debugging
      debugPrint('Platform: ${platformDispatcher.platformBrightness}');
      debugPrint('Locale: ${platformDispatcher.locales.first.languageCode}');
      debugPrint('View size: ${view.physicalSize}');
      debugPrint('Device pixel ratio: ${view.devicePixelRatio}');

      // Basic expectations about the environment
      expect(view.physicalSize.width > 0, isTrue);
      expect(view.physicalSize.height > 0, isTrue);
      expect(view.devicePixelRatio > 0, isTrue);

      // This allows us to verify the test is indeed running in a browser
      expect(isBrowserEnvironment, isTrue);
    });

    testWidgets('responsive widgets adapt to different screen sizes',
        (tester) async {
      // Save tester for tearDown
      sharedTester = tester;

      // Test with a small screen size
      setDisplaySize(tester, const Size(320, 480));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Get screen size using MediaQuery
              final size = MediaQuery.of(context).size;
              return Center(
                child: Text(
                    'Screen size: ${size.width.toInt()}x${size.height.toInt()}'),
              );
            },
          ),
        ),
      );

      expect(find.text('Screen size: 320x480'), findsOneWidget);

      // Change to a larger screen size
      setDisplaySize(tester, const Size(1024, 768));
      await tester.pump();

      expect(find.text('Screen size: 1024x768'), findsOneWidget);
    });
  });
}
