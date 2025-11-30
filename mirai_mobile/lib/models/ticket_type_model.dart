class TicketTypeModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int quota;
  final int remainingQuota;
  final String? createdAt;
  final String? updatedAt;

  TicketTypeModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.quota,
    required this.remainingQuota,
    this.createdAt,
    this.updatedAt,
  });

  factory TicketTypeModel.fromJson(Map<String, dynamic> json) {
    return TicketTypeModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: json['price'] is String
          ? double.parse(json['price'])
          : (json['price'] as num).toDouble(),
      quota: json['quota'] is String
          ? int.parse(json['quota'])
          : json['quota'] as int,
      remainingQuota: json['remaining_quota'] is String
          ? int.parse(json['remaining_quota'])
          : json['remaining_quota'] as int,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quota': quota,
      'remaining_quota': remainingQuota,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isAvailable => remainingQuota > 0;

  String get formattedPrice {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
