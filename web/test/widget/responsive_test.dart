import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Responsive layout adapts to mobile browser size',
      (WidgetTester tester) async {
    // Set mobile browser size
    tester.binding.window.physicalSizeTestValue = Size(375, 667);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

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
                    SizedBox(height: 20),
                    Container(
                      width: isSmallScreen ? width * 0.9 : width * 0.7,
                      padding: EdgeInsets.all(16),
                      color: Colors.blue.shade100,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter URL here',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            Size(isSmallScreen ? width * 0.9 : width * 0.3, 50),
                      ),
                      onPressed: () {},
                      child: Text('Shorten URL'),
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

    // Reset the test values
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
  });

  testWidgets('Responsive layout adapts to tablet browser size',
      (WidgetTester tester) async {
    // Set tablet browser size
    tester.binding.window.physicalSizeTestValue = Size(768, 1024);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

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
                    SizedBox(height: 20),
                    Container(
                      width: isSmallScreen ? width * 0.9 : width * 0.7,
                      padding: EdgeInsets.all(16),
                      color: Colors.blue.shade100,
                      child: TextField(
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

    // Reset the test values
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
  });

  testWidgets('Responsive layout adapts to desktop browser size',
      (WidgetTester tester) async {
    // Set desktop browser size
    tester.binding.window.physicalSizeTestValue = Size(1920, 1080);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

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
                      child: Column(
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
                          SizedBox(height: 20),
                          Container(
                            width: isSmallScreen
                                ? width * 0.9
                                : isLargeScreen
                                    ? width * 0.5
                                    : width * 0.7,
                            padding: EdgeInsets.all(16),
                            color: Colors.blue.shade100,
                            child: TextField(
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

    // Reset the test values
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
  });
}
