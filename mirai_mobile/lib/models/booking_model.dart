class BookingModel {
  final int id;
  final int userId;
  final int ticketTypeId;
  final String? ticketTypeName;
  final int quantity;
  final double totalPrice;
  final String? qrCode;
  final String? bookingCode;
  final String? paymentProof;
  final String paymentStatus;
  final String? createdAt;
  final String? updatedAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.ticketTypeId,
    this.ticketTypeName,
    required this.quantity,
    required this.totalPrice,
    this.qrCode,
    this.bookingCode,
    this.paymentProof,
    required this.paymentStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      userId: json['user_id'] is String
          ? int.parse(json['user_id'])
          : json['user_id'] as int,
      ticketTypeId: json['ticket_type_id'] is String
          ? int.parse(json['ticket_type_id'])
          : json['ticket_type_id'] as int,
      ticketTypeName: json['ticket_type_name'] as String?,
      quantity: json['quantity'] is String
          ? int.parse(json['quantity'])
          : json['quantity'] as int,
      totalPrice: json['total_price'] is String
          ? double.parse(json['total_price'])
          : (json['total_price'] as num).toDouble(),
      qrCode: json['qr_code'] as String?,
      bookingCode: json['booking_code'] as String?,
      paymentProof: json['payment_proof'] as String?,
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'ticket_type_id': ticketTypeId,
      'ticket_type_name': ticketTypeName,
      'quantity': quantity,
      'total_price': totalPrice,
      'qr_code': qrCode,
      'booking_code': bookingCode,
      'payment_proof': paymentProof,
      'payment_status': paymentStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get formattedPrice {
    return 'Rp ${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String get statusText {
    switch (paymentStatus) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return paymentStatus;
    }
  }

  bool get isPending => paymentStatus == 'pending';
  bool get isConfirmed => paymentStatus == 'confirmed';
  bool get isCancelled => paymentStatus == 'cancelled';
}
