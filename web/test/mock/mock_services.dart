import 'package:mockito/annotations.dart';
import 'package:link_shortener/services/url_service.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/services/recaptcha_service.dart';

@GenerateMocks([UrlService, AuthService, RecaptchaService])
void main() {}
