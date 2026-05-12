class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int isVerified; // Tambahkan ini

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.isVerified, // Tambahkan ini
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
      isVerified: json['is_verified'] ?? 0, // Ambil dari JSON
    );
  }
}
