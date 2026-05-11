import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/network_service.dart';
import '../models/donation_model.dart';

final myDonationsProvider = FutureProvider<List<DonationItem>>((ref) async {
  final dio = ref.watch(dioProvider);

  try {
    final response = await dio.get('/my-donation');

    // Karena Interceptor Anda sudah menjamin response adalah JSON
    if (response.statusCode == 200) {
      return MyDonationResponse.fromJson(response.data).data.donations;
    }
    return [];
  } catch (e) {
    // Error 401 dsb sudah ditangani interceptor,
    // di sini kita hanya melempar error untuk ditangkap UI
    throw Exception('Gagal mengambil data donasi: $e');
  }
});
