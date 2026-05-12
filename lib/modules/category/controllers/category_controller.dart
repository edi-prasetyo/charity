import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/public_service.dart';
import '../models/category_model.dart';

final categoryProvider = FutureProvider<List<Category>>((ref) async {
  final dio = ref.watch(publicProvider);
  final response = await dio.get('/categories');

  // Mengambil list dari key 'data' sesuai response API
  final List data = response.data['data'];
  return data.map((e) => Category.fromJson(e)).toList();
});

// Provider khusus Home (Hanya ambil 3)
final homeCategoryProvider = Provider<AsyncValue<List<Category>>>((ref) {
  return ref.watch(categoryProvider).whenData((list) => list.take(3).toList());
});
