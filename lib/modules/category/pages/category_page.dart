import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/category_controller.dart';
import '../widgets/category_card.dart';
import '../../campaign/pages/campaign_category_page.dart'; // Pastikan import ini ada

class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8FAFC,
      ), // Warna bg sedikit abu-abu agar card putih stand out
      appBar: AppBar(
        title: const Text("Pilih Kategori"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: categories.when(
        data: (data) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio:
                0.85, // Sesuaikan agar teks di bawah tidak terpotong
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final category = data[index];
            return CategoryCard(
              category: category,
              onTap: () {
                // NAVIGASI KE HALAMAN CAMPAIGN BERDASARKAN KATEGORI
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CampaignCategoryPage(
                      categoryId: category.id,
                      categoryName: category.name,
                    ),
                  ),
                );
              },
            );
          },
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF0D8456)),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Gagal memuat data"),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => ref.refresh(categoryProvider),
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
