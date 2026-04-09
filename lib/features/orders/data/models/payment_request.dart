class PaymentRequest {
  final int id;
  final int laundryId;
  final String status;
  final DateTime requestedAt;

  PaymentRequest({
    required this.id,
    required this.laundryId,
    required this.status,
    required this.requestedAt,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      id: json['id'] ?? 0,
      laundryId: json['laundry_id'] ?? 0,
      status: json['status'] ?? 'pending',
      requestedAt: DateTime.tryParse(json['requested_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'laundry_id': laundryId,
      'status': status,
      'requested_at': requestedAt.toIso8601String(),
    };
  }
}
