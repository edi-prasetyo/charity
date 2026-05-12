import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../core/constants/app_color.dart';
import '../../campaign/pages/campaign_category_page.dart';
import '../../category/controllers/category_controller.dart';
import '../../category/pages/category_page.dart';

class CategoryWidget extends ConsumerWidget {
  const CategoryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(homeCategoryProvider);

    return categoryAsync.when(
      data: (categories) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 Loop kategori dari API
            ...categories.map(
              (cat) => _buildItem(
                context,
                label: cat.name,
                image: cat.image, // ✅ kirim image
                icon: MingCuteIcons.mgc_hand_heart_line,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CampaignCategoryPage(
                        categoryId: cat.id,
                        categoryName: cat.name,
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🔥 Menu "Lainnya"
            _buildItem(
              context,
              label: "Lainnya",
              icon: MingCuteIcons.mgc_grid_fill,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoryPage()),
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    IconData? icon,
    String? image,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.separatorGrey,
                shape: BoxShape.circle,
              ),
              child: _buildIcon(image, icon),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 Widget untuk handle image / fallback icon
  Widget _buildIcon(String? image, IconData? icon) {
    if (image != null && image.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          image,
          width: 28,
          height: 28,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              icon ?? MingCuteIcons.mgc_hand_heart_line,
              color: AppColors.successColor,
              size: 28,
            );
          },
        ),
      );
    }

    return Icon(
      icon ?? MingCuteIcons.mgc_hand_heart_line,
      color: AppColors.primaryColor,
      size: 28,
    );
  }
}
