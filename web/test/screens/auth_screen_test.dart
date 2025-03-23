import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/screens/auth_screen.dart';
import 'package:link_shortener/widgets/auth/oauth_provider_button.dart';

import '../mocks/mock_auth_service.dart';
import '../test_helper.dart';

void main() {
  late TestAppConfig testConfig;
  late MockAuthService testAuthService;

  setUp(() {
    testConfig = TestAppConfig();
    testAuthService = MockAuthService();
  });

  tearDown(() {
    testAuthService.dispose();
  });

  group('AuthScreen', () {
    testWidgets('displays all OAuth provider buttons', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          authService: testAuthService,
          child: const AuthScreen(),
        ),
      );

      // Удостоверимся, что все виджеты построены
      await tester.pumpAndSettle();

      // Check for provider buttons
      expect(find.byType(OAuthProviderButton), findsNWidgets(3));
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('Continue with GitHub'), findsOneWidget);
      
      // Закроем все асинхронные операции перед завершением теста
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
  });
}
