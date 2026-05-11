import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import '../../campaign/pages/donation_payment_webview.dart';
import '../models/donation_model.dart';

class DonationDetailPage extends StatelessWidget {
  final DonationItem donation;

  const DonationDetailPage({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    final bool isPending = donation.payment.status == 'pending';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Detail Donasi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Ikon Status Besar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                isPending
                    ? MingCuteIcons.mgc_time_line
                    : MingCuteIcons.mgc_check_circle_line,
                size: 40,
                color: isPending ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isPending ? 'Menunggu Pembayaran' : 'Donasi Berhasil',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Rincian Informasi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildDetailRow('ID Transaksi', '#${donation.id}'),
                  _buildDetailRow(
                    'Tanggal',
                    DateFormat('dd MMM yyyy, HH:mm').format(donation.createdAt),
                  ),
                  const Divider(height: 30),
                  // _buildDetailRow(
                  //   'Kampanye',
                  //   donation.campaign.title,
                  //   isMultiLine: true,
                  // ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Total Donasi',
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(donation.amount),
                    isBoldValue: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isPending
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonationPaymentWebview(
                        paymentUrl: donation.payment.paymentUrl!,
                        externalId: "INV-${donation.id}",
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Lanjutkan Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMultiLine = false,
    bool isBoldValue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: isMultiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isBoldValue ? FontWeight.w800 : FontWeight.w500,
                fontSize: isBoldValue ? 15 : 13,
                color: isBoldValue ? Colors.blue : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
