import 'dart:developer' as dev; // Tambahkan import ini
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/network_service.dart';

class CampaignDonationController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    return null;
  }

  Future<void> submitDonation({
    required int campaignId,
    required int amount,
    required String name,
    required String email,
    required String phone,
    String? message,
    required bool isAnonymous,
  }) async {
    dev.log(
      'Starting donation process for campaign: $campaignId',
      name: 'DONATION',
    );
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final dio = ref.read(dioProvider);

      // Log data yang dikirim
      final payload = {
        'campaign_id': campaignId,
        'amount': amount,
        'name': name,
        'email': email,
        'phone': phone,
        'message': message,
        'is_anonymous': isAnonymous ? 1 : 0,
      };
      dev.log('Sending payload: $payload', name: 'DONATION');

      try {
        final response = await dio.post(
          '/campaigns/$campaignId/donate',
          data: payload,
        );

        dev.log('Response received: ${response.statusCode}', name: 'DONATION');
        dev.log('Response body: ${response.data}', name: 'DONATION');

        if (response.data['success'] == true) {
          final paymentUrl = response.data['data']?['payment_url'];

          if (paymentUrl == null) throw 'Link pembayaran tidak ditemukan.';

          dev.log('Success! Returning payment URL to UI', name: 'DONATION');

          // KUNCINYA: Cukup return string URL saja, jangan panggil launchUrl di sini
          return paymentUrl;
        } else {
          final errMsg = response.data['message'] ?? 'Gagal memproses donasi';
          dev.log('API Business Error: $errMsg', name: 'DONATION');
          throw errMsg;
        }
      } catch (e, stack) {
        dev.log(
          'Critical Error: $e',
          name: 'DONATION',
          error: e,
          stackTrace: stack,
        );
        rethrow;
      }
    });
  }
}

final donationControllerProvider =
    AsyncNotifierProvider.autoDispose<CampaignDonationController, String?>(
      () => CampaignDonationController(),
    );
