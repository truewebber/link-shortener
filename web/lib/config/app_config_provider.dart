import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:link_shortener/config/app_config.dart';

/// Provider for the app configuration
/// 
/// Makes the app configuration available to all widgets in the tree
class AppConfigProvider extends InheritedWidget {

  /// Creates a new app configuration provider
  const AppConfigProvider({
    super.key,
    required this.config,
    required super.child,
  });
  /// The app configuration
  final AppConfig config;

  @override
  bool updateShouldNotify(AppConfigProvider oldWidget) => config != oldWidget.config;

  /// Gets the app configuration from the widget tree
  static AppConfig of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppConfigProvider>()!.config;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AppConfig>('config', config));
  }
}
