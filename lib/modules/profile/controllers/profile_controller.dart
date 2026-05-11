import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/network_service.dart';
import '../models/profile_model.dart';

final profileProvider = FutureProvider<ProfileModel>((ref) async {
  final dio = ref.read(dioProvider);

  final response = await dio.get('/profile');

  if (response.data['status'] == 'ok') {
    return ProfileModel.fromJson(response.data['data']);
  } else {
    throw Exception(response.data['message'] ?? 'Failed to fetch profile');
  }
});
