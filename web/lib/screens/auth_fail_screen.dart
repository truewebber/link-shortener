import 'package:flutter/material.dart';

/// Screen displayed when authentication fails
class AuthFailScreen extends StatelessWidget {
  /// Creates a new auth fail screen
  const AuthFailScreen({
    super.key,
    required this.error,
  });

  /// The error message
  final String error;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Authentication Failed'),
      backgroundColor: Theme.of(context).colorScheme.error,
      foregroundColor: Theme.of(context).colorScheme.onError,
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 64,
          ),
          const SizedBox(height: 24),
          Text(
            'Authentication Failed',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
            child: const Text('Return to Home'),
          ),
        ],
      ),
    ),
  );
}
