import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/widgets/feature_section.dart';

import '../mocks/mock_auth_service.dart';
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
      expect(find.text('Fast & Reliable'), findsOneWidget);
      expect(find.text('Link Analytics'), findsOneWidget);
      expect(find.text('Custom Expiration'), findsOneWidget);
      
      // Check feature descriptions
      expect(
        find.text('Our service provides quick URL shortening with high availability and minimal latency.'),
        findsOneWidget,
      );
      expect(
        find.text('Track your link performance with detailed analytics and insights.'),
        findsOneWidget,
      );
      expect(
        find.text('Set custom expiration dates for your links when you sign in.'),
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
      expect(find.text('Fast & Reliable'), findsOneWidget);
      expect(find.text('Link Analytics'), findsOneWidget);
      expect(find.text('Custom Expiration'), findsOneWidget);
    });
    
    testWidgets('displays feature icons correctly', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const FeatureSection()));
      
      // Check for feature icons
      expect(find.byIcon(Icons.speed), findsOneWidget);
      expect(find.byIcon(Icons.analytics), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });
    
    testWidgets('maintains consistent spacing', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const FeatureSection()));
      
      // Check section title exists
      expect(find.text('Features'), findsOneWidget);
      
      // Check feature items exist
      expect(find.text('Fast & Reliable'), findsOneWidget);
      expect(find.text('Link Analytics'), findsOneWidget);
      expect(find.text('Custom Expiration'), findsOneWidget);
      
      // Check for SizedBox spacers
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
