import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/auth_model.dart';
import '../../../core/services/network_service.dart';
import '../../../core/services/secure_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthResponse?>(() {
      return AuthController();
    });

class AuthController extends AsyncNotifier<AuthResponse?> {
  @override
  FutureOr<AuthResponse?> build() async {
    final token = await ref.read(secureStorageProvider).getToken();
    final refresh = await ref.read(secureStorageProvider).getRefreshToken();
    final expiresStr = await ref.read(secureStorageProvider).getExpiresIn();

    if (token != null && refresh != null) {
      final expires = int.tryParse(expiresStr ?? '0') ?? 0;
      print('DEBUG: [AUTH_START] Memulihkan sesi. Expiry: $expires');

      return AuthResponse(
        accessToken: token,
        refreshToken: refresh,
        expiresIn: expires,
      );
    }

    print('DEBUG: [AUTH_START] Tidak ada sesi ditemukan.');
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final dio = ref.read(dioProvider);

      // --- AMBIL FCM TOKEN ---
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
        print('DEBUG: [FCM_TOKEN] Berhasil mendapatkan token: $fcmToken');
      } catch (e) {
        print('DEBUG: [FCM_TOKEN] Gagal mendapatkan token: $e');
        // Tetap lanjut login meskipun FCM gagal (opsional, tergantung kebijakan Anda)
      }

      final response = await dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
          'fcm_token': fcmToken, // Tambahkan di sini
        },
      );

      final authData = AuthResponse.fromJson(response.data);

      await ref
          .read(secureStorageProvider)
          .saveTokens(
            authData.accessToken,
            authData.refreshToken,
            authData.expiresIn,
          );

      print('DEBUG: [LOGIN] Berhasil. Expiry: ${authData.expiresIn}');
      return authData;
    });
  }

  Future<bool> refreshToken() async {
    try {
      final refresh = await ref.read(secureStorageProvider).getRefreshToken();
      if (refresh == null) throw Exception("No Refresh Token Found");

      print('DEBUG: [REFRESH] Menjalankan request refresh...');

      final dio = Dio();
      final response = await dio.post(
        '${ApiService.baseUrl}/refresh',
        data: {'refresh_token': refresh},
      );

      final newData = AuthResponse.fromJson(response.data);

      await ref
          .read(secureStorageProvider)
          .saveTokens(
            newData.accessToken,
            newData.refreshToken,
            newData.expiresIn,
          );

      // KUNCI: Update state agar UI tetap sinkron
      state = AsyncData(newData);

      print('DEBUG: [REFRESH] Berhasil memperbarui token.');
      return true;
    } catch (e) {
      print('DEBUG: [REFRESH] Gagal: $e. Melakukan auto-logout...');

      // Jika refresh gagal, bersihkan semua & kembalikan ke Login via Wrapper
      await ref.read(secureStorageProvider).clearAll();

      // KUNCI: Set state ke null untuk mentrigger redirect di AuthWrapper
      state = const AsyncData(null);
      return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading(); // Set loading di awal proses
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/logout');
    } catch (e) {
      print('DEBUG: [LOGOUT] Gagal tapi tetap hapus lokal.');
    } finally {
      await ref.read(secureStorageProvider).clearAll();
      state = const AsyncData(null); // Selesai loading dan data jadi null
    }
  }

  Future<void> checkSession() async {
    try {
      final dio = ref.read(dioProvider);
      // Request ini akan memicu interceptor jika token expired
      await dio.get('/me');
      print("DEBUG: [SESSION] Token masih valid.");
    } on DioException catch (e) {
      print(
        "DEBUG: [SESSION] Sesi bermasalah (DioError): ${e.response?.statusCode}",
      );

      // Jika interceptor gagal melakukan refresh, dia akan melempar error kembali ke sini.
      // Jika statusnya 401 dan refresh sudah gagal, pastikan state null.
      if (e.response?.statusCode == 401) {
        await ref.read(secureStorageProvider).clearAll();
        state = const AsyncData(null);
      }
    } catch (e) {
      print("DEBUG: [SESSION] Error tidak dikenal: $e");
    }
  }
}
