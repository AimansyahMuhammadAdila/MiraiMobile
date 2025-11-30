class BookingModel {
  final int id;
  final int userId;
  final int ticketTypeId;
  final int quantity;
  final double totalPrice;
  final String qrCode;
  final String bookingCode;
  final String paymentStatus;
  final String? ticketName;
  final String? ticketDescription;
  final String? createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.ticketTypeId,
    required this.quantity,
    required this.totalPrice,
    required this.qrCode,
    required this.bookingCode,
    required this.paymentStatus,
    this.ticketName,
    this.ticketDescription,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      ticketTypeId: json['ticket_type_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
      qrCode: json['qr_code'] ?? '',
      bookingCode: json['booking_code'] ?? '',
      paymentStatus: json['payment_status'] ?? 'pending',
      ticketName: json['ticket_name'],
      ticketDescription: json['ticket_description'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'ticket_type_id': ticketTypeId,
      'quantity': quantity,
      'total_price': totalPrice,
      'qr_code': qrCode,
      'booking_code': bookingCode,
      'payment_status': paymentStatus,
      'ticket_name': ticketName,
      'ticket_description': ticketDescription,
      'created_at': createdAt,
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
