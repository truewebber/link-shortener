import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:link_shortener/config/app_config.dart';
import 'package:link_shortener/config/app_config_provider.dart';
import 'package:link_shortener/screens/home_screen.dart';

/// The entry point of the application
void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  final config = _loadConfiguration();
  
  // Set up error logging for debug mode
  if (kDebugMode) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      // print('Flutter error: ${details.exception}');
      // print('Stack trace: ${details.stack}');
    };
    
    print('Starting Link Shortener App...');
    print('API Base URL: ${config.apiBaseUrl}');
    print('Environment: ${config.environment}');
  }
  
  // Run the app
  runApp(LinkShortenerApp(config: config));
}

/// Loads the application configuration
AppConfig _loadConfiguration() {
  // In a real app, we would load from environment, file, or server
  // For development we use predefined values
  
  // Debug logging - only in non-production
  if (kDebugMode) {
    // Use logger instead of print in a real app
  }
  
  // Use production-like values
  return const AppConfig(
    apiBaseUrl: 'https://api.shortener.example.com',
    environment: 'development',
  );
}

/// The main application widget
class LinkShortenerApp extends StatelessWidget {

  /// Creates a new instance of the app
  const LinkShortenerApp({
    super.key,
    required this.config,
  });
  /// The application configuration
  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Building LinkShortenerApp');
    }
    
    return AppConfigProvider(
      config: config,
      child: MaterialApp(
        title: 'Link Shortener',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff6750a4),
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff6750a4),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AppConfig>('config', config));
  }
} 