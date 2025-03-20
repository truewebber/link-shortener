import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/widgets/feature_section.dart';
import '../test_helper.dart';

void main() {
  late TestAppConfig testConfig;
  
  setUp(() {
    testConfig = TestAppConfig();
  });
  
  group('FeatureSection', () {
    testWidgets('displays all features', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const FeatureSection(),
        ),
      );
      
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
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const FeatureSection(),
        ),
      );
      
      // Test desktop layout (>900px)
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pump();
      expect(find.byType(Row), findsOneWidget);
      
      // Test tablet layout (600-900px)
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pump();
      expect(find.byType(Column), findsOneWidget);
      
      // Test mobile layout (<600px)
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();
      expect(find.byType(Column), findsOneWidget);
    });
    
    testWidgets('displays feature icons correctly', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const FeatureSection(),
        ),
      );
      
      // Check for feature icons
      expect(find.byIcon(Icons.speed), findsOneWidget);
      expect(find.byIcon(Icons.analytics), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });
    
    testWidgets('maintains consistent spacing', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const FeatureSection(),
        ),
      );
      
      // Check section title spacing
      final titleFinder = find.text('Features');
      final titleRect = tester.getRect(titleFinder);
      expect(titleRect.top, greaterThan(0));
      
      // Check feature items spacing
      final featureItems = find.byType(Column);
      expect(featureItems, findsNWidgets(3));
      
      // Verify padding between items
      final firstItemRect = tester.getRect(featureItems.first);
      final secondItemRect = tester.getRect(featureItems.at(1));
      expect(
        secondItemRect.top - firstItemRect.bottom,
        greaterThanOrEqualTo(32),
      );
    });
  });
}
