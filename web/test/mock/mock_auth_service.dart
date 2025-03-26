import 'package:flutter/material.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:mockito/mockito.dart';

class MockAuthService extends Mock implements AuthService {
  @override
  Future<Map<String, String>> getAuthHeaders({BuildContext? context}) async => {
      'Authorization': 'Bearer mock-token',
      'Content-Type': 'application/json',
    };

  @override
  bool get isAuthenticated => true;
}
