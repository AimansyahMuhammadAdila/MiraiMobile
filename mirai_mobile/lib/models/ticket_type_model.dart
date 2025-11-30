class TicketTypeModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int quota;
  final int remainingQuota;
  final bool isAvailable;
  final int sold;

  TicketTypeModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.quota,
    required this.remainingQuota,
    required this.isAvailable,
    required this.sold,
  });

  factory TicketTypeModel.fromJson(Map<String, dynamic> json) {
    return TicketTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quota: json['quota'] ?? 0,
      remainingQuota: json['remaining_quota'] ?? 0,
      isAvailable: json['is_available'] ?? false,
      sold: json['sold'] ?? 0,
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
      'is_available': isAvailable,
      'sold': sold,
    };
  }

  String get formattedPrice {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
