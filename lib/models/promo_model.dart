class Promo {
  final int id;
  final String title;
  final String? description;
  final String? promoCode;
  final String? image;
  final String? targetType;
  final String discountType;
  final double discountValue;
  final double? minTransaction;
  final double? maxDiscount;
  final int quota;
  final int usedQuota;
  final String? startDate;
  final String? endDate;
  final bool isActive;
  final bool isExpired;
  final bool isQuotaHabis;
  final int sortOrder;

  const Promo({
    required this.id,
    required this.title,
    this.description,
    this.promoCode,
    this.image,
    this.targetType,
    required this.discountType,
    required this.discountValue,
    this.minTransaction,
    this.maxDiscount,
    required this.quota,
    required this.usedQuota,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.isExpired,
    required this.isQuotaHabis,
    required this.sortOrder,
  });

  factory Promo.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    int parseInt(dynamic val, [int fallback = 0]) {
      if (val == null) return fallback;
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? fallback;
      if (val is double) return val.toInt();
      return fallback;
    }

    return Promo(
      id:             parseInt(json['id']),
      title:          json['title'] ?? '',
      description:    json['description'],
      promoCode:      json['promo_code'],
      image:          json['image'],
      targetType:     json['target_type'],
      discountType:   json['discount_type'] ?? 'fixed',
      discountValue:  parseDouble(json['discount_value']) ?? 0.0,
      minTransaction: parseDouble(json['min_transaction']),
      maxDiscount:    parseDouble(json['max_discount']),
      quota:          parseInt(json['quota']),
      usedQuota:      parseInt(json['used_quota']),
      startDate:      json['start_date']?.toString(),
      endDate:        json['end_date']?.toString(),
      isActive:       json['is_active'] == true || json['is_active'] == 1,
      isExpired:      json['is_expired'] == true || json['is_expired'] == 1,
      isQuotaHabis:   json['is_quota_habis'] == true || json['is_quota_habis'] == 1,
      sortOrder:      parseInt(json['sort_order']),
    );
  }

  String get discountLabel {
    if (discountType == 'percent') return '${discountValue.toInt()}%';
    return 'Rp ${discountValue.toInt()}';
  }

  int get sisaKuota => quota > 0 ? quota - usedQuota : 999;

  bool get bisaDipakai => isActive && !isExpired && !isQuotaHabis;
}