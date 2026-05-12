import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_model.dart';
import '../controllers/auth_controller.dart';
import '../../../core/services/public_service.dart';
import '../../../core/services/secure_services.dart';

// Gunakan AsyncNotifierProvider (tanpa AutoDispose jika ingin state persis)
final registerControllerProvider =
    AsyncNotifierProvider<RegisterController, void>(() {
      return RegisterController();
    });

class RegisterController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Return null atau void karena kita hanya menggunakan notifier ini untuk action
    return null;
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncLoading();

    // Gunakan try-catch manual atau state = await AsyncValue.guard
    state = await AsyncValue.guard(() async {
      final dio = ref.read(publicProvider);

      final response = await dio.post(
        '/register',
        data: {
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
          "password_confirmation": passwordConfirmation,
        },
      );

      final String token = response.data['access_token'];
      // Cek boolean dari response API kamu
      final int isVerified = response.data['user']['is_verified'] == true
          ? 1
          : 0;

      final secureService = ref.read(secureStorageProvider);
      await secureService.saveTokens(token, '', 3600);
      await secureService.saveIsVerified(isVerified.toString());

      // UPDATE: Di Riverpod 3, cara update provider lain dari notifier:
      ref.read(authControllerProvider.notifier).state = AsyncData(
        AuthResponse(
          accessToken: token,
          refreshToken: '',
          expiresIn: 3600,
          isVerified: isVerified,
        ),
      );
    });
  }
}
