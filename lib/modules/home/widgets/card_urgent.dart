import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../campaign/controllers/campaign_controller.dart';
import '../../campaign/widgets/campaign_card.dart'; // Import CampaignCard yang sudah kita lengkapi

class UrgentCampaign extends ConsumerWidget {
  const UrgentCampaign({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urgentCampaigns = ref.watch(urgentCampaignProvider);

    return urgentCampaigns.when(
      data: (campaigns) {
        if (campaigns.isEmpty) {
          return const Center(child: Text("Tidak ada campaign mendesak"));
        }

        return ListView.builder(
          shrinkWrap:
              true, // Penting karena berada di dalam SingleChildScrollView
          physics:
              const NeverScrollableScrollPhysics(), // Scroll diatur oleh parent
          itemCount: campaigns.length,
          itemBuilder: (context, index) {
            final campaign = campaigns[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CampaignCard(campaign: campaign),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text("Error: $error")),
    );
  }
}
