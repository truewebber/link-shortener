import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../util/browser_detection.dart';

void main() {
  testWidgets('Responsive layout adapts to mobile browser size',
      (tester) async {
    // Set mobile browser size using non-deprecated API
    setDisplaySize(tester, const Size(375, 667));

    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final width = MediaQuery.of(context).size.width;
            // Simple responsive layout test
            final isSmallScreen = width < 600;
            return Scaffold(
              appBar: AppBar(
                title: Text(isSmallScreen ? 'Mobile View' : 'Larger View'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSmallScreen ? 'Mobile Layout' : 'Larger Layout',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: isSmallScreen ? width * 0.9 : width * 0.7,
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue.shade100,
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter URL here',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            Size(isSmallScreen ? width * 0.9 : width * 0.3, 50),
                      ),
                      onPressed: () {},
                      child: const Text('Shorten URL'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    // Assert
    expect(find.text('Mobile View'), findsOneWidget);
    expect(find.text('Mobile Layout'), findsOneWidget);

    // Reset the test values using non-deprecated APIs
    addTearDown(() => clearPhysicalSizeTestValue(tester));
    addTearDown(() => clearDevicePixelRatioTestValue(tester));
  });

  testWidgets('Responsive layout adapts to tablet browser size',
      (tester) async {
    // Set tablet browser size using non-deprecated API
    setDisplaySize(tester, const Size(768, 1024));

    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final width = MediaQuery.of(context).size.width;
            // Simple responsive layout test
            final isSmallScreen = width < 600;
            return Scaffold(
              appBar: AppBar(
                title: Text(isSmallScreen ? 'Mobile View' : 'Larger View'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSmallScreen ? 'Mobile Layout' : 'Larger Layout',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: isSmallScreen ? width * 0.9 : width * 0.7,
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue.shade100,
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter URL here',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    // Assert
    expect(find.text('Larger View'), findsOneWidget);
    expect(find.text('Larger Layout'), findsOneWidget);

    // Reset the test values using non-deprecated APIs
    addTearDown(() => clearPhysicalSizeTestValue(tester));
    addTearDown(() => clearDevicePixelRatioTestValue(tester));
  });

  testWidgets('Responsive layout adapts to desktop browser size',
      (tester) async {
    // Set desktop browser size using non-deprecated API
    setDisplaySize(tester, const Size(1920, 1080));

    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final width = MediaQuery.of(context).size.width;
            // Simple responsive layout test
            final isSmallScreen = width < 600;
            final isLargeScreen = width > 1200;
            return Scaffold(
              appBar: AppBar(
                title: Text(isSmallScreen
                    ? 'Mobile View'
                    : isLargeScreen
                        ? 'Desktop View'
                        : 'Tablet View'),
              ),
              body: Row(
                children: [
                  if (isLargeScreen)
                    Container(
                      width: 250,
                      color: Colors.blue.shade50,
                      child: const Column(
                        children: [
                          ListTile(title: Text('Dashboard')),
                          ListTile(title: Text('My URLs')),
                          ListTile(title: Text('Profile')),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isSmallScreen
                                ? 'Mobile Layout'
                                : isLargeScreen
                                    ? 'Desktop Layout'
                                    : 'Tablet Layout',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: isSmallScreen
                                ? width * 0.9
                                : isLargeScreen
                                    ? width * 0.5
                                    : width * 0.7,
                            padding: const EdgeInsets.all(16),
                            color: Colors.blue.shade100,
                            child: const TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter URL here',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    // Assert
    expect(find.text('Desktop View'), findsOneWidget);
    expect(find.text('Desktop Layout'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget); // Sidebar is shown

    // Reset the test values using non-deprecated APIs
    addTearDown(() => clearPhysicalSizeTestValue(tester));
    addTearDown(() => clearDevicePixelRatioTestValue(tester));
  });
}
