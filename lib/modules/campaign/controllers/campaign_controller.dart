import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/public_service.dart';
import '../models/campaign_model.dart';

// Provider untuk fetch list campaigns
final campaignListProvider = FutureProvider<List<Campaign>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/campaigns');

  // Masuk ke data -> data (karena response berstruktur pagination Laravel)
  final List listData = response.data['data']['data'];
  return listData.map((e) => Campaign.fromJson(e)).toList();
});

final latestCampaignProvider = Provider<AsyncValue<List<Campaign>>>((ref) {
  // Mengambil data dari campaignListProvider yang sudah kamu buat
  final allCampaigns = ref.watch(campaignListProvider);

  return allCampaigns.whenData((list) {
    // Mengambil 5 campaign pertama (terbaru)
    return list.take(5).toList();
  });
});

// Provider untuk fetch detail campaign berdasarkan ID
final campaignDetailProvider = FutureProvider.family<Campaign, int>((
  ref,
  id,
) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/campaigns/$id');

  return Campaign.fromJson(response.data['data']);
});

// Provider untuk fetch campaigns berdasarkan kategori ID
final campaignsByCategoryProvider = FutureProvider.family<List<Campaign>, int>((
  ref,
  categoryId,
) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/campaigns/category/$categoryId');

  // Masuk ke data -> data (struktur paginasi Laravel)
  final List listData = response.data['data']['data'];
  return listData.map((e) => Campaign.fromJson(e)).toList();
});

final campaignDonationsProvider = FutureProvider.family<List<Donation>, int>((
  ref,
  id,
) async {
  final dio = ref.watch(
    dioProvider,
  ); // Pastikan dioProvider sudah dikonfigurasi
  final response = await dio.get('/campaigns/$id/donations');

  // Ambil list dari response.data['data']['data']
  final List listData = response.data['data']['data'];

  return listData.map((e) => Donation.fromJson(e)).toList();
});

// Provider untuk mengambil campaign yang mendesak (Urgent)
// Diurutkan berdasarkan sisa hari paling sedikit (daysLeft)
final urgentCampaignProvider = Provider<AsyncValue<List<Campaign>>>((ref) {
  final allCampaigns = ref.watch(campaignListProvider);

  return allCampaigns.whenData((list) {
    // 1. Filter: Hanya ambil yang belum berakhir (daysLeft > 0)
    // 2. Sort: Urutkan dari yang sisa harinya paling dikit ke paling banyak
    final urgentList = list
        .where((campaign) => campaign.daysLeft >= 0)
        .toList();

    urgentList.sort((a, b) {
      // Bandingkan selisih waktu dari sekarang ke endDate
      final durationA = a.endDate.difference(DateTime.now());
      final durationB = b.endDate.difference(DateTime.now());
      return durationA.compareTo(durationB);
    });

    // Ambil 5 teratas yang paling mendekati tenggat waktu
    return urgentList.take(3).toList();
  });
});
