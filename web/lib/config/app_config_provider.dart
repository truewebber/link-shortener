import 'package:flutter/material.dart';
import 'app_config.dart';

class AppConfigProvider extends InheritedWidget {
  final AppConfig config;

  const AppConfigProvider({
    super.key,
    required this.config,
    required super.child,
  });

  static AppConfig of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppConfigProvider>();
    assert(provider != null, 'No AppConfigProvider found in context');
    return provider!.config;
  }

  @override
  bool updateShouldNotify(AppConfigProvider oldWidget) => config != oldWidget.config;
}
