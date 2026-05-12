import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider((ref) => const SecureService());

class SecureService {
  final _storage = const FlutterSecureStorage();
  const SecureService();
  static const _keyIsVerified = 'is_verified';

  Future<void> saveIsVerified(String status) async {
    await _storage.write(key: _keyIsVerified, value: status);
  }

  Future<String?> getIsVerified() async {
    return await _storage.read(key: _keyIsVerified);
  }

  Future<void> saveTokens(String access, String refresh, int expires) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
    await _storage.write(key: 'expires_in', value: expires.toString());
  }

  Future<String?> getToken() => _storage.read(key: 'access_token');
  Future<String?> getRefreshToken() => _storage.read(key: 'refresh_token');
  Future<String?> getExpiresIn() => _storage.read(key: 'expires_in');
  Future<void> clearAll() => _storage.deleteAll();
}
