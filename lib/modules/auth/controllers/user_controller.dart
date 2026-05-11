import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/network_service.dart'; // Tempat dioProvider berada
import '../models/user_model.dart';

final userProfileProvider = FutureProvider<User>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/me');

  return User.fromJson(response.data);
});
