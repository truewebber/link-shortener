import 'dart:async';
import 'package:mockito/mockito.dart';

class MockRecaptchaInterop extends Mock {
  Future<String> execute(String siteKey, dynamic options) => Future.value('mock-recaptcha-token');
}

class MockWindow extends Mock {
  dynamic get recaptcha => MockRecaptchaInterop();
}
