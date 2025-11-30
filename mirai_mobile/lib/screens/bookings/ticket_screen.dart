import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mirai_mobile/models/booking_model.dart';
import 'package:mirai_mobile/utils/constants.dart';

class TicketScreen extends StatelessWidget {
  final BookingModel booking;

  const TicketScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E-Ticket')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // E-Ticket Card
            Card(
              child: Container(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  gradient: AppConstants.primaryGradient,
                ),
                child: Column(
                  children: [
                    // Event Name
                    Text(
                      AppConstants.eventName,
                      style: Theme.of(
                        context,
                      ).textTheme.displaySmall?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // QR Code or Bank Info
                    if (booking.isConfirmed && booking.qrCode != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMedium,
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              '${AppConstants.apiBaseUrl}/media/qr_codes/${booking.qrCode!.split('/').last}',
                          width: 250,
                          height: 250,
                          placeholder: (context, url) => const SizedBox(
                            width: 250,
                            height: 250,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => const SizedBox(
                            width: 250,
                            height: 250,
                            child: Icon(Icons.error, size: 60),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Scan QR Code ini di pintu masuk',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ] else if (booking.isPending) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMedium,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.account_balance,
                              size: 48,
                              color: AppConstants.primaryPurple,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Silakan Transfer ke:',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'BCA 1234567890',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: AppConstants.primaryPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'a.n. PT Mirai Mobile',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              'Total Pembayaran:',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking.formattedPrice,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Booking Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Booking',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    _DetailRow(
                      label: 'Booking Code',
                      value: booking.bookingCode ?? 'N/A',
                    ),
                    _DetailRow(
                      label: 'Jenis Tiket',
                      value: booking.ticketTypeName ?? '-',
                    ),
                    _DetailRow(
                      label: 'Jumlah',
                      value: '${booking.quantity}x Tiket',
                    ),
                    _DetailRow(
                      label: 'Total Harga',
                      value: booking.formattedPrice,
                      valueColor: AppConstants.primaryPurple,
                    ),
                    _DetailRow(
                      label: 'Status Pembayaran',
                      value: booking.statusText,
                      valueColor: booking.isConfirmed
                          ? Colors.green
                          : booking.isPending
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppConstants.primaryCyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppConstants.primaryCyan),
                      const SizedBox(width: 8),
                      Text(
                        'Petunjuk',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppConstants.primaryCyan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Tunjukkan QR Code ini di pintu masuk event\n'
                    '• QR Code dapat di-scan langsung dari HP\n'
                    '• Simpan screenshot untuk backup\n'
                    '• Jangan bagikan QR Code ke orang lain',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
