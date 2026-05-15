import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../modules/auth/models/auth_model.dart';
import 'api_service.dart';
import 'secure_services.dart';
import '../../modules/auth/controllers/auth_controller.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiService.baseUrl,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // Flag untuk mencegah multiple refresh & infinite loop
  bool isRefreshing = false;

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await ref.read(secureStorageProvider).getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        final path = error.requestOptions.path;

        // 1. Cek status 401 dan pastikan bukan dari endpoint krusial
        if (error.response?.statusCode == 401 &&
            !path.contains('/login') &&
            !path.contains('/refresh')) {
          if (!isRefreshing) {
            isRefreshing = true;

            try {
              print('DEBUG: [INTERCEPTOR] Menjalankan Refresh Token...');

              final refreshToken = await ref
                  .read(secureStorageProvider)
                  .getRefreshToken();

              // 2. Hit API Refresh langsung di sini (Tanpa fungsi di Controller)
              final refreshDio =
                  Dio(); // Pakai instance baru agar tidak masuk interceptor ini
              final response = await refreshDio.post(
                '${ApiService.baseUrl}/refresh',
                data: {'refresh_token': refreshToken},
              );

              final newData = AuthResponse.fromJson(response.data);

              // 3. Simpan ke Secure Storage
              await ref
                  .read(secureStorageProvider)
                  .saveTokens(
                    newData.accessToken,
                    newData.refreshToken,
                    newData.expiresIn,
                  );

              // 4. Update State AuthController secara paksa agar UI Sinkron
              // Ini penting agar state global aplikasi tidak jadi null/logout
              ref.read(authControllerProvider.notifier).updateState(newData);

              isRefreshing = false;

              // 5. Ulangi Request yang gagal tadi
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer ${newData.accessToken}';

              final retryResponse = await dio.fetch(opts);
              return handler.resolve(retryResponse);
            } catch (e) {
              isRefreshing = false;
              print('DEBUG: [INTERCEPTOR] Refresh Gagal total: $e');

              // Jika refresh gagal, paksa logout melalui controller
              ref.read(authControllerProvider.notifier).logout();
              return handler.next(error);
            }
          }
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});
