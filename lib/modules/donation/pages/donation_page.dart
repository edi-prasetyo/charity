import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../core/constants/app_color.dart';
import '../controllers/donation_controller.dart';
import '../widgets/donation_card_widget.dart';

class DonationPage extends ConsumerWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mendengarkan data dari provider
    final donationsAsync = ref.watch(myDonationsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBody,
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
        // Menggunakan ref.refresh untuk memicu penarikan data ulang dari API
        onRefresh: () => ref.refresh(myDonationsProvider.future),
        child: donationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => SingleChildScrollView(
            // physics ini penting agar halaman error tetap bisa ditarik untuk refresh
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Center(child: Text('Terjadi kesalahan: $err')),
            ),
          ),
          data: (donations) {
            if (donations.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height:
                      MediaQuery.of(context).size.height *
                      0.7, // Sesuaikan tinggi
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ikon MingCute (Gunakan package ming_cute_icons)
                      Icon(
                        MingCuteIcons.mgc_paper_line,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Tidak Ada Donasi...',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Anda belum memiliki riwayat donasi. Mulailah berbagi kebaikan hari ini!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              // physics ini penting agar daftar pendek tetap bisa ditarik untuk refresh
              physics: const AlwaysScrollableScrollPhysics(),
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
