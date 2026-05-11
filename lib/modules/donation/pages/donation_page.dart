import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../campaign/pages/donation_payment_webview.dart';
import '../controllers/donation_controller.dart';
import '../widgets/donation_card_widget.dart';

class DonationPage extends ConsumerWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mendengarkan data dari provider
    final donationsAsync = ref.watch(myDonationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Donasi Saya',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        // Trigger refresh data
        onRefresh: () => ref.refresh(myDonationsProvider.future),
        child: donationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Terjadi kesalahan: $err')),
          data: (donations) {
            if (donations.isEmpty) {
              return const Center(child: Text('Belum ada riwayat donasi'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: donations.length,
              itemBuilder: (context, index) {
                final donation = donations[index];
                return DonationCardWidget(donation: donation);
              },
            );
          },
        ),
      ),
    );
  }
}
