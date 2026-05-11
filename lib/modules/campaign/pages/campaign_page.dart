import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/campaign_controller.dart';
import '../widgets/campaign_card.dart';

class CampaignPage extends ConsumerWidget {
  const CampaignPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(campaignListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Daftar Campaign"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: campaignsAsync.when(
        data: (campaigns) {
          if (campaigns.isEmpty) {
            return const Center(child: Text("Belum ada campaign saat ini"));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              return CampaignCard(campaign: campaigns[index]);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF0D8456)),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Gagal mengambil data campaign"),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(campaignListProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D8456),
                ),
                child: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
