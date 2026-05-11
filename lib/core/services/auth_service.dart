import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_services.dart';

class AuthService {
  final SecureService _secureService;

  AuthService(this._secureService);

  // Check if token exists
  Future<bool> isLoggedIn() async {
    final token = await _secureService.getToken();
    return token != null;
  }

  // Logout user
  Future<void> logout() async {
    // Corrected to use the clearAll() method from your SecureService
    await _secureService.clearAll();
  }
}

// Create a provider for AuthService that depends on secureStorageProvider
final authServiceProvider = Provider((ref) {
  final secureService = ref.watch(secureStorageProvider);
  return AuthService(secureService);
});
