import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:link_shortener/services/auth_service.dart';

/// Screen displayed when returning from OAuth provider
class OAuthCallbackScreen extends StatefulWidget {
  /// Creates a new OAuth callback screen
  const OAuthCallbackScreen({
    super.key,
    required this.code,
    required this.provider,
  });

  /// The authorization code from the provider
  final String code;
  
  /// The OAuth provider name (google, apple, github)
  final String provider;

  @override
  State<OAuthCallbackScreen> createState() => _OAuthCallbackScreenState();
}

class _OAuthCallbackScreenState extends State<OAuthCallbackScreen> {
  final _authService = AuthService();
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _processCallback();
  }
  
  Future<void> _processCallback() async {
    try {
      if (kDebugMode) {
        print('Processing OAuth callback for provider: ${widget.provider}');
        print('Code: ${widget.code.substring(0, 10)}...');
      }
      
      // Handle the OAuth callback with the auth service
      await _authService.handleOAuthCallback(widget.code, widget.provider);
      
      // Navigate back to home screen on success
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during OAuth callback: $e');
      }
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication failed: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Signing In'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Completing authentication...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Authentication Failed',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage ?? 'An unknown error occurred',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
      ),
    );
}
