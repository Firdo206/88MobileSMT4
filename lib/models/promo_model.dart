class Promo {
  final int id;
  final String title;
  final String targetType;
  final int targetId;
  final String discountType;
  final double discountValue;
  final DateTime startTime;
  final DateTime endTime;
  final int quota;
  final int usedQuota;
  final bool isActive;

  Promo({
    required this.id,
    required this.title,
    required this.targetType,
    required this.targetId,
    required this.discountType,
    required this.discountValue,
    required this.startTime,
    required this.endTime,
    required this.quota,
    required this.usedQuota,
    required this.isActive,
  });

  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      id: json['id'],
      title: json['title'],
      targetType: json['target_type'],
      targetId: json['target_id'],
      discountType: json['discount_type'],
      discountValue: double.parse(json['discount_value'].toString()),
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      quota: json['quota'],
      usedQuota: json['used_quota'],
      isActive: json['is_active'] == 1,
    );
  }
}