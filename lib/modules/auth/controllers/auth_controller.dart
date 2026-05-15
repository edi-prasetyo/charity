import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/network_service.dart';
import '../../profile/controllers/profile_controller.dart';
import '../models/auth_model.dart';
import '../../../core/services/public_service.dart';
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
    final verifiedStr = await ref
        .read(secureStorageProvider)
        .getIsVerified(); // Ambil dari storage

    if (token != null && refresh != null) {
      return AuthResponse(
        accessToken: token,
        refreshToken: refresh,
        expiresIn: int.tryParse(expiresStr ?? '0') ?? 0,
        isVerified: int.tryParse(verifiedStr ?? '0') ?? 0,
      );
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final dio = ref.read(publicProvider);

      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print('DEBUG: [FCM_TOKEN] Gagal: $e');
      }

      final response = await dio.post(
        '/login',
        data: {'email': email, 'password': password, 'fcm_token': fcmToken},
      );

      final authData = AuthResponse.fromJson(response.data);

      // 1. Pastikan simpan token selesai sempurna
      await ref
          .read(secureStorageProvider)
          .saveTokens(
            authData.accessToken,
            authData.refreshToken,
            authData.expiresIn,
          );

      await ref
          .read(secureStorageProvider)
          .saveIsVerified(authData.isVerified.toString());

      // JANGAN panggil invalidate di sini jika bikin error,
      // kita gunakan cara di bawah (poin 2)
      return authData;
    });
  }

  Future<bool> forgotPassword(String email) async {
    try {
      // Kita tidak mengubah state utama menjadi loading agar tidak mengganggu UI Login
      final dio = ref.read(publicProvider);
      final response = await dio.post(
        '/forgot-password',
        data: {"email": email},
        // Gunakan header null untuk menghindari masalah Unauthenticated jika ada token lama
        options: Options(headers: {'Authorization': null}),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('DEBUG: [FORGOT_PASSWORD] Gagal: $e');
      rethrow;
    }
  }

  Future verifyOtp(String email, String otp) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/verify-otp',
        data: {"email": email, "otp": otp},
      );

      if (response.statusCode == 200) {
        // 1. Ambil data saat ini
        final currentData = state.value;

        if (currentData != null) {
          // 2. Buat objek baru dengan status isVerified = 1
          final updatedData = AuthResponse(
            accessToken: currentData.accessToken,
            refreshToken: currentData.refreshToken,
            expiresIn: currentData.expiresIn,
            isVerified: 1, // Set manual ke aktif
          );

          // 3. Simpan perubahan ke Secure Storage agar saat restart tidak balik ke VerifyPage
          await ref.read(secureStorageProvider).saveIsVerified("1");

          // 4. Update state global
          state = AsyncData(updatedData);
        }

        print('DEBUG: [VERIFY_OTP] Berhasil diverifikasi.');
        return true;
      }
      return false;
    } catch (e) {
      print('DEBUG: [VERIFY_OTP] Gagal: $e');
      // Jika gagal, kembalikan state sebelumnya agar loading berhenti
      state = AsyncData(state.value);
      rethrow; // Biarkan UI menangkap error untuk menampilkan SnackBar
    }
  }

  Future<bool> resendOtp(String email) async {
    // Kita tidak set state = loading agar UI tidak blank,
    // tapi kita return boolean agar tombol di UI bisa tahu hasilnya.
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/resend-otp', data: {"email": email});

      if (response.statusCode == 200) {
        print('DEBUG: [RESEND_OTP] ${response.data['message']}');
        return true;
      }
      return false;
    } catch (e) {
      print('DEBUG: [RESEND_OTP] Gagal: $e');
      rethrow;
    }
  }

  // Future<bool> refreshToken() async {
  //   try {
  //     final refresh = await ref.read(secureStorageProvider).getRefreshToken();
  //     if (refresh == null) return false;

  //     // Gunakan instance Dio baru (tanpa interceptor auth) untuk request refresh
  //     final dioRefresh = Dio();
  //     final response = await dioRefresh.post(
  //       '${ApiService.baseUrl}/refresh',
  //       data: {'refresh_token': refresh},
  //     );

  //     final newData = AuthResponse.fromJson(response.data);

  //     // Update Storage
  //     await ref
  //         .read(secureStorageProvider)
  //         .saveTokens(
  //           newData.accessToken,
  //           newData.refreshToken,
  //           newData.expiresIn,
  //         );

  //     // Update State (Penting agar UI tetap sinkron)
  //     state = AsyncData(newData);
  //     return true;
  //   } catch (e) {
  //     // Jika refresh gagal (misal refresh token expired), langsung logout
  //     await logout();
  //     return false;
  //   }
  // }

  void updateState(AuthResponse newData) {
    state = AsyncData(newData);
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/logout');
    } catch (e) {
      debugPrint('DEBUG: [LOGOUT] API Gagal: $e');
    } finally {
      // 1. Bersihkan storage
      await ref.read(secureStorageProvider).clearAll();

      // 2. Set state ke null.
      // Karena profileProvider me-watch provider ini,
      // dia akan otomatis re-build/error saat state jadi null.
      state = const AsyncData(null);
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
