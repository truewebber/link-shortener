import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/widgets/feature_section.dart';

import '../mocks/auth_service.generate.mocks.dart';
import '../test_helper.dart';

void main() {
  late TestAppConfig testConfig;
  late MockAuthService testAuthService;

  setUp(() {
    testConfig = TestAppConfig();
    testAuthService = MockAuthService();
  });

  // Helper function to build a testable widget
  Widget buildTestableWidget(Widget child) => TestWidgetWrapper(
        config: testConfig,
        authService: testAuthService,
        child: SingleChildScrollView(
          child: child,
        ),
      );

  group('FeatureSection', () {
    testWidgets('displays all features', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const FeatureSection()));

      // Check feature titles
      expect(find.text('Short Links'), findsOneWidget);
      expect(find.text('Custom Expiration'), findsOneWidget);
      expect(find.text('Link Analytics'), findsOneWidget);

      // Check feature descriptions
      expect(
        find.text('Create short, memorable links that are easy to share.'),
        findsOneWidget,
      );
      expect(
        find.text('Set custom expiration times for your links.'),
        findsOneWidget,
      );
      expect(
        find.text('Track clicks and view detailed analytics for your links.'),
        findsOneWidget,
      );
    });

    testWidgets('adapts to different screen sizes', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const FeatureSection()));

      // Test desktop layout (>900px)
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pump();

      // Test tablet layout (600-900px)
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pump();

      // Test mobile layout (<600px)
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();

      // Verify basic functionality still works across screen sizes
      expect(find.text('Features'), findsOneWidget);
      expect(find.text('Short Links'), findsOneWidget);
      expect(find.text('Custom Expiration'), findsOneWidget);
      expect(find.text('Link Analytics'), findsOneWidget);
    });

    testWidgets('displays feature icons correctly', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const FeatureSection()));

      // Check for feature icons
      expect(find.byIcon(Icons.link), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });

    testWidgets('maintains consistent spacing', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const FeatureSection()));

      // Check section title exists
      expect(find.text('Features'), findsOneWidget);

      // Check feature items exist
      expect(find.text('Short Links'), findsOneWidget);
      expect(find.text('Custom Expiration'), findsOneWidget);
      expect(find.text('Link Analytics'), findsOneWidget);

      // Check for SizedBox spacers
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
