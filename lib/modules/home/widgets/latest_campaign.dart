import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../campaign/controllers/campaign_controller.dart';
import 'card_widget.dart';

class LatestCampaign extends ConsumerWidget {
  const LatestCampaign({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestCampaigns = ref.watch(latestCampaignProvider);

    return latestCampaigns.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
      data: (campaigns) {
        if (campaigns.isEmpty) {
          return const Center(child: Text("Belum ada campaign terbaru"));
        }

        return SizedBox(
          height: 280, // Sesuaikan dengan tinggi kartu
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: campaigns.length,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (context, index) {
              return CampaignCard(campaign: campaigns[index]);
            },
          ),
        );
      },
    );
  }
}
