import 'package:flutter/material.dart';
import 'package:link_shortener/models/auth/auth_state.dart';

class AuthStatusIndicator extends StatelessWidget {
  const AuthStatusIndicator({
    super.key,
    required this.status,
    this.errorMessage,
    this.onRetry,
  });

  final AuthenticationStatus status;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AuthenticationStatus.authenticating:
        return _buildAuthenticatingState();
      case AuthenticationStatus.error:
        return _buildErrorState(context);
      case AuthenticationStatus.authenticated:
        return _buildSuccessState(context);
      case AuthenticationStatus.initial:
      return const SizedBox.shrink();
    }
  }

  Widget _buildAuthenticatingState() => const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Authenticating...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

  Widget _buildErrorState(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text(
                'Authentication Failed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade700,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );

  Widget _buildSuccessState(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Text(
            'Authentication Successful',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
}
