import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../campaign/models/campaign_model.dart';
import '../../campaign/pages/campaign_detail_page.dart';
import '../../../core/constants/app_color.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;

  const CampaignCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampaignDetailPage(campaignId: campaign.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar dengan Badge Nama Kategori
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: campaign.imageThumb != null
                        ? CachedNetworkImage(
                            imageUrl: campaign.imageThumb!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                _buildPlaceholder(),
                            placeholder: (context, url) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                // --- MENAMPILKAN NAMA KATEGORI ---
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      campaign
                          .category
                          .name, // Dari model: campaign.category.name
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Progress Bar
                  LinearProgressIndicator(
                    value: campaign.progress,
                    backgroundColor: Colors.grey[200],
                    color: AppColors.primaryColor,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 12),

                  // Informasi Dana & Sisa Hari
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Terkumpul",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Text(
                            currencyFormatter.format(
                              campaign.currentAmount ?? 0,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          // --- MENAMPILKAN TARGET AMOUNT ---
                          Text(
                            "dari ${currencyFormatter.format(campaign.targetAmount)}",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      // Sisa Hari
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${campaign.daysLeft} hari lagi",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }
}
