class MyDonationResponse {
  final String status;
  final String message;
  final DonationData data;

  MyDonationResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MyDonationResponse.fromJson(Map<String, dynamic> json) =>
      MyDonationResponse(
        status: json["status"],
        message: json["message"],
        data: DonationData.fromJson(json["data"]),
      );
}

class DonationData {
  final List<DonationItem> donations;
  final int total;

  DonationData({required this.donations, required this.total});

  factory DonationData.fromJson(Map<String, dynamic> json) => DonationData(
    donations: List<DonationItem>.from(
      json["data"].map((x) => DonationItem.fromJson(x)),
    ),
    total: json["total"],
  );
}

class DonationItem {
  final int id;
  final int amount;
  final DateTime createdAt;
  final Campaign campaign;
  final Payment payment;

  DonationItem({
    required this.id,
    required this.amount,
    required this.createdAt,
    required this.campaign,
    required this.payment,
  });

  factory DonationItem.fromJson(Map<String, dynamic> json) => DonationItem(
    id: json["id"],
    amount: json["amount"],
    createdAt: DateTime.parse(json["created_at"]),
    campaign: Campaign.fromJson(json["campaign"]),
    payment: Payment.fromJson(json["payment"]),
  );
}

class Campaign {
  final String description;
  Campaign({required this.description});
  factory Campaign.fromJson(Map<String, dynamic> json) =>
      Campaign(description: json["description"]);
}

class Payment {
  final String status;
  final String? paymentUrl;
  Payment({required this.status, this.paymentUrl});
  factory Payment.fromJson(Map<String, dynamic> json) =>
      Payment(status: json["status"], paymentUrl: json["payment_url"]);
}
