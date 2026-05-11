import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'secure_services.dart';
import '../../modules/auth/controllers/auth_controller.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiService.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      // PERBAIKAN 1: Tambahkan header ini agar Laravel mengirim JSON, bukan HTML
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await ref.read(secureStorageProvider).getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          print(
            'DEBUG: [DIO] Mengirim Request dengan Token: ${token.substring(0, 10)}...',
          );
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // PERBAIKAN 2: Pastikan pengecekan error lebih kuat
        print('DEBUG: [DIO] Terjadi Error: ${error.response?.statusCode}');

        // Jika status 401 (Unauthorized)
        if (error.response?.statusCode == 401) {
          print('DEBUG: [DIO] Access Token Expired. Mencoba Refresh Token...');

          final success = await ref
              .read(authControllerProvider.notifier)
              .refreshToken();

          if (success) {
            print('DEBUG: [DIO] Refresh Berhasil. Mengulang request...');

            // Ambil token baru dari storage
            final newToken = await ref.read(secureStorageProvider).getToken();

            // Update header request yang gagal tadi
            error.requestOptions.headers['Authorization'] = 'Bearer $newToken';

            // PERBAIKAN 3: Gunakan instance dio yang sama untuk retry
            try {
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } on DioException catch (e) {
              return handler.next(e);
            }
          } else {
            print('DEBUG: [DIO] Refresh Gagal. State otomatis jadi null.');
            // Jangan lupa kirim error ke handler agar catch di controller terpanggil
            return handler.next(error);
          }
        }

        return handler.next(error);
      },
    ),
  );

  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  return dio;
});
