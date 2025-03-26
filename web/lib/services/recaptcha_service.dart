import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:js/js_util.dart';
import 'package:link_shortener/config/app_config.dart';
import 'package:link_shortener/js/recaptcha_interop.dart';
import 'package:universal_html/html.dart' as html;

class RecaptchaService {
  factory RecaptchaService() => _instance;
  RecaptchaService._internal();
  
  static final RecaptchaService _instance = RecaptchaService._internal();
  
  static const String _scriptUrl = 'https://www.google.com/recaptcha/api.js?render=';

  late String _siteKey;
  late bool _isProduction;

  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    if (!kIsWeb) {
      throw UnsupportedError('reCAPTCHA is only supported in web environments');
    }

    final config = AppConfig.fromWindow();
    _isProduction = config.isProduction;
    _siteKey = config.googleCaptchaSiteKey;

    if (!_isProduction) {
      _isInitialized = true;
      return;
    }
    
    final completer = Completer<void>();
    
    final script = html.ScriptElement()
      ..src = '$_scriptUrl$_siteKey'
      ..async = true
      ..onLoad.listen((_) {
        // Wait a bit to ensure reCAPTCHA is fully initialized
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        });
      })
      ..onError.listen((event) {
        if (!completer.isCompleted) {
          completer.completeError('Failed to load reCAPTCHA script: $event');
        }
      });
    
    html.document.head?.children.add(script);
    
    try {
      await completer.future;
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing reCAPTCHA: $e');
      rethrow;
    }
  }
  
  Future<String> execute(String action) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Return a dummy token if not in production
    if (!_isProduction) {
      debugPrint('reCAPTCHA bypassed in non production environment');
      return 'dev_mode_token';
    }
    
    try {
      final promise = Recaptcha.execute(_siteKey, jsify({'action': action}));
      final token = await promise.asFuture<String>();
      return token;
    } catch (e) {
      debugPrint('reCAPTCHA error: $e');
      rethrow;
    }
  }
}
