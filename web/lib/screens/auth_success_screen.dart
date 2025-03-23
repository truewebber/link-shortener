import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:link_shortener/models/auth/user_session.dart';
import 'package:link_shortener/services/auth_service.dart';

/// Screen displayed when authentication is successful
class AuthSuccessScreen extends StatefulWidget {
  /// Creates a new auth success screen
  const AuthSuccessScreen({
    super.key,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAtMS,
  });

  /// The access token from OAuth provider
  final String accessToken;
  
  /// The refresh token from OAuth provider
  final String refreshToken;
  
  /// Token expiration timestamp (UTC milliseconds)
  final int expiresAtMS;

  @override
  State<AuthSuccessScreen> createState() => _AuthSuccessScreenState();
}

class _AuthSuccessScreenState extends State<AuthSuccessScreen> {
  final _authService = AuthService();
  bool _isProcessing = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _processAuth();
  }
  
  Future<void> _processAuth() async {
    try {
      // Create a session from received parameters
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(widget.expiresAtMS);

      if (kDebugMode) {
        print('Processing successful authentication');
        print('Access Token: ${widget.accessToken.substring(0, 10)}...');
        print('Expires at: ${expiresAt.toIso8601String()} (UTC)');
      }

      final session = UserSession(
        token: widget.accessToken,
        refreshToken: widget.refreshToken,
        expiresAt: expiresAt,
      );
      
      // Save session
      await _authService.saveSession(session);
      
      // Navigate to home screen on success
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        // Navigate after a short delay to show success message
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/');
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing authentication: $e');
      }
      
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Failed to complete authentication: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: _isProcessing 
        ? const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Completing authentication...'),
            ],
          )
        : _errorMessage != null
          ? Column(
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
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                  child: const Text('Go Back'),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Successfully Authenticated',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text('Redirecting to home page...'),
              ],
            ),
    ),
  );
}
