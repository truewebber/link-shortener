import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:link_shortener/models/auth/auth_state.dart';
import 'package:link_shortener/models/auth/oauth_provider.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/widgets/auth/auth_status_indicator.dart';
import 'package:link_shortener/widgets/auth/oauth_provider_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthenticationStatus _status = AuthenticationStatus.initial;
  String? _errorMessage;
  final _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Building AuthScreen');
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive design based on width
                final maxWidth = constraints.maxWidth > 500 ? 500.0 : constraints.maxWidth;
                
                return Container(
                  width: maxWidth,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to manage your links',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Auth Status Indicator
                      if (_status != AuthenticationStatus.initial) ...[
                        AuthStatusIndicator(
                          status: _status,
                          errorMessage: _errorMessage,
                          onRetry: _status == AuthenticationStatus.error ? _resetAuthState : null,
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // If authenticating, show progress and hide buttons
                      if (_status != AuthenticationStatus.authenticating) ...[
                        // OAuth Provider Buttons
                        Column(
                          children: [
                            OAuthProviderButton(
                              provider: OAuthProvider.google,
                              onPressed: () => _handleOAuthSignIn(OAuthProvider.google),
                            ),
                            const SizedBox(height: 16),
                            OAuthProviderButton(
                              provider: OAuthProvider.apple,
                              onPressed: () => _handleOAuthSignIn(OAuthProvider.apple),
                            ),
                            const SizedBox(height: 16),
                            OAuthProviderButton(
                              provider: OAuthProvider.github,
                              onPressed: () => _handleOAuthSignIn(OAuthProvider.github),
                            ),
                          ],
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      Text(
                        'By signing in, you agree to our Terms of Service and Privacy Policy',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _handleOAuthSignIn(OAuthProvider provider) async {
    // Update state to show loading
    setState(() {
      _status = AuthenticationStatus.authenticating;
      _errorMessage = null;
    });
    
    try {
      // Call the auth service
      await _authService.signInWithOAuth(provider);
      
      // Update state to show success
      setState(() {
        _status = AuthenticationStatus.authenticated;
      });
      
      // Delay to show success message and then navigate back
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Update state to show error
      setState(() {
        _status = AuthenticationStatus.error;
        _errorMessage = 'Failed to authenticate: ${e.toString()}';
      });
    }
  }
  
  void _resetAuthState() {
    setState(() {
      _status = AuthenticationStatus.initial;
      _errorMessage = null;
    });
  }
}
