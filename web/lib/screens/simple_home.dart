import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Building SimpleHomeScreen');
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Home'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hello, Flutter Web!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (kDebugMode) {
                  print('Button pressed');
                }
              },
              child: const Text('Click Me'),
            ),
          ],
        ),
      ),
    );
  }
} 