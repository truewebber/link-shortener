import 'package:link_shortener/services/recaptcha_service.dart';
import 'package:mockito/mockito.dart';

class MockRecaptchaService extends Mock implements RecaptchaService {
  @override
  Future<String> execute(String action) async => 'mock-recaptcha-token';

  @override
  Future<void> initialize() async {
    // Do nothing for tests
  }
}
