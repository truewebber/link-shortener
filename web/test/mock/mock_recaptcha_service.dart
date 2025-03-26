import 'package:mockito/mockito.dart';
import 'package:link_shortener/services/recaptcha_service.dart';

class MockRecaptchaService extends Mock implements RecaptchaService {
  @override
  Future<String> execute(String action) async {
    return 'mock-recaptcha-token';
  }

  @override
  Future<void> initialize() async {
    // Do nothing for tests
  }
}
