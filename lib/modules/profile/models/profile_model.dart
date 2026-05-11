class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final bool isVerified;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isVerified,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Helper untuk menangani jika ID datang sebagai String dari API
    int parseId(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return ProfileModel(
      // Seringkali ID di API berubah antara String/Int tergantung konfigurasi DB
      id: parseId(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      // Menangani is_verified jika dikirim sebagai String "1" atau Int 1
      isVerified: json['is_verified'].toString() == "1",
    );
  }
}
