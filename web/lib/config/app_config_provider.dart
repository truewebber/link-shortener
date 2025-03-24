import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:link_shortener/config/app_config.dart';

class AppConfigProvider extends InheritedWidget {
  const AppConfigProvider({
    super.key,
    required this.config,
    required super.child,
  });

  final AppConfig config;

  @override
  bool updateShouldNotify(AppConfigProvider oldWidget) => config != oldWidget.config;

  static AppConfig of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppConfigProvider>()!.config;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AppConfig>('config', config));
  }
}
