import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/network_service.dart';
import '../models/donation_model.dart';

final myDonationsProvider = FutureProvider<List<DonationItem>>((ref) async {
  final authService = ref.read(authServiceProvider);
  final isLogin = await authService.isLoggedIn();

  if (!isLogin) {
    return []; // 🚫 STOP di sini
  }

  final dio = ref.read(dioProvider); // 🔥 pakai read, bukan watch

  final response = await dio.get('/my-donation');

  if (response.statusCode == 200) {
    return MyDonationResponse.fromJson(response.data).data.donations;
  }

  return [];
});
