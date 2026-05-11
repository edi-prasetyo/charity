import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:intl/intl.dart';
import '../controllers/campaign_store_controller.dart';
import '../models/campaign_model.dart';
import 'donation_payment_webview.dart';

class DonationPreviewPage extends ConsumerWidget {
  final Map<String, dynamic> donationData;
  final Campaign campaign;

  const DonationPreviewPage({
    super.key,
    required this.donationData,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen terhadap perubahan state untuk navigasi ke WebView
    ref.listen<AsyncValue<String?>>(donationControllerProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (paymentUrl) {
          if (paymentUrl != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DonationPaymentWebview(
                  paymentUrl: paymentUrl,
                  externalId:
                      "DON-${campaign.id}-${DateTime.now().millisecondsSinceEpoch}",
                ),
              ),
            );
          }
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        loading: () {},
      );
    });

    final donationState = ref.watch(donationControllerProvider);
    final isLoading = donationState is AsyncLoading;

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft background color
      appBar: AppBar(
        title: const Text(
          'Konfirmasi Donasi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Icon Success/Review
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      MingCuteIcons.mgc_paper_line,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tinjau Donasi Anda',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pastikan semua data di bawah sudah benar',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // Card Rincian
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Bagian Amount
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.03),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'TOTAL DONASI',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormat.format(
                                  int.parse(donationData['amount'].toString()),
                                ),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bagian Detail Data
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildDetailItem(
                                MingCuteIcons.mgc_coin_2_fill,
                                'Program',
                                campaign.title,
                                isBold: true,
                              ),
                              const Divider(height: 32),
                              _buildDetailItem(
                                MingCuteIcons.mgc_user_3_line,
                                'Donatur',
                                donationData['is_anonymous'] == true
                                    ? 'Hamba Allah (Anonim)'
                                    : donationData['name'],
                              ),
                              _buildDetailItem(
                                MingCuteIcons.mgc_mail_line,
                                'Email',
                                donationData['email'],
                              ),
                              _buildDetailItem(
                                MingCuteIcons.mgc_phone_line,
                                'WhatsApp',
                                donationData['phone'],
                              ),
                              if (donationData['message'] != null &&
                                  donationData['message']
                                      .toString()
                                      .isNotEmpty) ...[
                                const Divider(height: 32),
                                _buildDetailItem(
                                  MingCuteIcons.mgc_chat_2_line,
                                  'Pesan & Doa',
                                  donationData['message'],
                                  isMultiline: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Area
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      MingCuteIcons.mgc_shield_line,
                      size: 14,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pembayaran aman & terenkripsi',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            ref
                                .read(donationControllerProvider.notifier)
                                .submitDonation(
                                  campaignId: campaign.id,
                                  amount: int.parse(
                                    donationData['amount'].toString(),
                                  ),
                                  name: donationData['name'],
                                  email: donationData['email'],
                                  phone: donationData['phone'],
                                  message: donationData['message'],
                                  isAnonymous: donationData['is_anonymous'],
                                );
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Konfirmasi & Bayar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                MingCuteIcons.mgc_arrow_right_line,
                                size: 20,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value, {
    bool isBold = false,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: isMultiline ? 5 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
