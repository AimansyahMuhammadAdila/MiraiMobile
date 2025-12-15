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
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      userId: json['user_id'] is String
          ? int.parse(json['user_id'])
          : json['user_id'],
      ticketTypeId: json['ticket_type_id'] is String
          ? int.parse(json['ticket_type_id'])
          : json['ticket_type_id'],
      ticketTypeName: json['ticket_type_name'],
      quantity: json['quantity'] is String
          ? int.parse(json['quantity'])
          : json['quantity'],
      totalPrice: json['total_price'] is String
          ? double.parse(json['total_price'])
          : (json['total_price'] as num).toDouble(),
      qrCode: json['qr_code'],
      bookingCode: json['booking_code'],
      paymentProof: json['payment_proof'],
      paymentStatus: json['payment_status'] ?? 'unpaid',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // =============================
  // STATUS GETTER (PENTING)
  // =============================

  bool get isUnpaid => paymentStatus == 'unpaid';
  bool get isPending => paymentStatus == 'pending';
  bool get isWaitingApproval => paymentStatus == 'waiting_approval';
  bool get isConfirmed => paymentStatus == 'confirmed';
  bool get canUpload => paymentStatus == 'unpaid' || paymentStatus == 'pending';
  bool get isCancelled => paymentStatus == 'cancelled';

  // =============================
  // STATUS TEXT (UI)
  // =============================

  String get statusText {
    switch (paymentStatus) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'waiting_approval':
        return 'Menunggu Verifikasi Admin';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return paymentStatus;
    }
  }

  String get formattedPrice {
    return 'Rp ${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (m) => '${m[1]}.')}';
  }
}
