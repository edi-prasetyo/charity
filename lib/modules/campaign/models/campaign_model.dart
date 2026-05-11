class Campaign {
  final int id;
  final int categoryId;
  final String title;
  final String? imageThumb;
  final String? image;
  final String? description;
  final int targetAmount;
  final int? currentAmount;
  final DateTime endDate;
  final int? totalDonors;
  final CampaignCategory category;

  Campaign({
    required this.id,
    required this.categoryId,
    required this.title,
    this.imageThumb,
    this.image,
    this.description,
    required this.targetAmount,
    this.currentAmount, // 2. Hapus 'required' jika ingin benar-benar opsional
    required this.endDate,
    required this.category,
    this.totalDonors,
  });

  double get progress {
    if (targetAmount == 0) return 0.0;
    // 3. Gunakan null-coalescing (??) untuk memberikan nilai default 0 saat perhitungan
    final calc = (currentAmount ?? 0) / targetAmount;
    return calc > 1.0 ? 1.0 : calc;
  }

  int get daysLeft {
    final difference = endDate.difference(DateTime.now()).inDays;
    return difference < 0 ? 0 : difference;
  }

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'],
      categoryId: json['category_id'],
      title: json['title'],
      imageThumb: json['image_thumb'],
      image: json['image'],
      description: json['description'],
      targetAmount: (json['target_amount'] as num?)?.toInt() ?? 0,
      // 4. Tambahkan safety check di factory method
      currentAmount: json['current_amount'] != null
          ? (json['current_amount'] as num).toInt()
          : 0, // atau biarkan null tergantung kebutuhan
      endDate: DateTime.parse(json['end_date']),
      totalDonors: json['total_donors'],
      category: CampaignCategory.fromJson(json['category']),
    );
  }
}

class CampaignCategory {
  final int id;
  final String name;

  CampaignCategory({required this.id, required this.name});

  factory CampaignCategory.fromJson(Map<String, dynamic> json) {
    return CampaignCategory(id: json['id'], name: json['name']);
  }
}

class Donation {
  final int id;
  final String name;
  final int amount;
  final String? message;
  final bool isAnonymous;
  final DateTime createdAt;

  Donation({
    required this.id,
    required this.name,
    required this.amount,
    this.message,
    required this.isAnonymous,
    required this.createdAt,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      // Jika anonim, paksa tampilkan "Hamba Allah",
      // jika tidak gunakan field 'name' dari JSON
      name: json['is_anonymous'] == 1
          ? "Hamba Allah"
          : (json['name'] ?? "Donatur"),
      amount: json['amount'] ?? 0,
      message: json['message'],
      isAnonymous: json['is_anonymous'] == 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
