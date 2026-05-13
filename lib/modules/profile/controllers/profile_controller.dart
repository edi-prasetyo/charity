import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/network_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/profile_model.dart';

final profileProvider = FutureProvider.autoDispose<ProfileModel>((ref) async {
  // 1. Pantau status auth.
  // Jika user login, authState akan berubah, dan profileProvider otomatis jalan ulang.
  final authState = ref.watch(authControllerProvider);

  // 2. Jika sedang loading login, atau data login belum ada, jangan tembak API dulu.
  if (authState is AsyncLoading) {
    // Biarkan UI profile menampilkan loading juga
    return Future.delayed(
      const Duration(days: 1),
    ).then((_) => throw 'Loading...');
  }

  if (authState.value == null) {
    throw Exception("Sesi belum tersedia");
  }

  // 3. Ambil dio
  final dio = ref.read(dioProvider);

  // 4. Eksekusi API
  final response = await dio.get('/profile');

  if (response.data['status'] == 'ok') {
    return ProfileModel.fromJson(response.data['data']);
  } else {
    throw Exception(response.data['message'] ?? 'Gagal fetch profile');
  }
});

final updatePasswordProvider = FutureProvider.family
    .autoDispose<String, Map<String, String>>((ref, body) async {
      final dio = ref.read(dioProvider);

      final response = await dio.post('/profile/password', data: body);

      if (response.data['status'] == 'success') {
        return response.data['message'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal update password');
      }
    });
