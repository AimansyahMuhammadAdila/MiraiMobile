import 'package:flutter/material.dart';
import 'package:mirai_mobile/models/booking_model.dart';
import 'package:mirai_mobile/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TicketQRScreen extends StatelessWidget {
  final BookingModel booking;

  const TicketQRScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E-Ticket')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'TERVERIFIKASI',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // QR Code
            if (booking.qrCode != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CachedNetworkImage(
                  imageUrl:
                      '${AppConstants.apiBaseUrl}/media/qr_codes/${booking.qrCode!.split('/').last}',
                  width: 250,
                  height: 250,
                  placeholder: (context, url) => Container(
                    width: 250,
                    height: 250,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 250,
                    height: 250,
                    child: const Icon(Icons.error, size: 60),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tunjukkan QR code ini saat masuk event',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppConstants.textGray),
                textAlign: TextAlign.center,
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.qr_code, size: 80, color: AppConstants.textGray),
                    const SizedBox(height: 16),
                    Text(
                      'QR Code belum tersedia',
                      style: TextStyle(color: AppConstants.textGray),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Ticket Details
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.backgroundDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Tiket',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Kode Booking', booking.bookingCode ?? 'N/A'),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Status',
                    booking.paymentStatus.toUpperCase(),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Jumlah', '${booking.quantity}x Tiket'),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Total',
                    'Rp ${booking.totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppConstants.primaryPurple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Informasi Penting',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('• Simpan screenshot QR code ini'),
                  const Text('• Tunjukkan saat scan masuk event'),
                  const Text('• Satu QR code untuk semua tiket'),
                  const Text('• Jangan bagikan QR code ke orang lain'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppConstants.textGray)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
