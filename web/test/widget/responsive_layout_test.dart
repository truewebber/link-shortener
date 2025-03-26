import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../util/browser_detection.dart';

/// A responsive container that changes layout based on screen width
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Different layouts based on screen size
    if (screenWidth < 600) {
      return const Center(
        child: Text('Mobile Layout', key: Key('mobile_layout')),
      );
    } else if (screenWidth < 1200) {
      return const Center(
        child: Text('Tablet Layout', key: Key('tablet_layout')),
      );
    } else {
      return const Center(
        child: Text('Desktop Layout', key: Key('desktop_layout')),
      );
    }
  }
}

void main() {
  group('Responsive Layout Tests', () {
    // Setup to capture the tester for use in tearDown
    late WidgetTester sharedTester;

    // Using proper tearDown to reset view properties
    tearDown(() {
      clearPhysicalSizeTestValue(sharedTester);
      clearDevicePixelRatioTestValue(sharedTester);
    });

    testWidgets('displays mobile layout on small screens',
        (tester) async {
      // Save tester for tearDown
      sharedTester = tester;

      // Set a mobile-sized screen using non-deprecated API
      setDisplaySize(tester, const Size(400, 800));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(),
          ),
        ),
      );

      expect(find.byKey(const Key('mobile_layout')), findsOneWidget);
      expect(find.byKey(const Key('tablet_layout')), findsNothing);
      expect(find.byKey(const Key('desktop_layout')), findsNothing);
    });

    testWidgets('displays tablet layout on medium screens',
        (tester) async {
      // Save tester for tearDown
      sharedTester = tester;

      // Set a tablet-sized screen using non-deprecated API
      setDisplaySize(tester, const Size(800, 1024));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(),
          ),
        ),
      );

      expect(find.byKey(const Key('mobile_layout')), findsNothing);
      expect(find.byKey(const Key('tablet_layout')), findsOneWidget);
      expect(find.byKey(const Key('desktop_layout')), findsNothing);
    });

    testWidgets('displays desktop layout on large screens',
        (tester) async {
      // Save tester for tearDown
      sharedTester = tester;

      // Set a desktop-sized screen using non-deprecated API
      setDisplaySize(tester, const Size(1400, 900));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(),
          ),
        ),
      );

      expect(find.byKey(const Key('mobile_layout')), findsNothing);
      expect(find.byKey(const Key('tablet_layout')), findsNothing);
      expect(find.byKey(const Key('desktop_layout')), findsOneWidget);
    });
  });
}
