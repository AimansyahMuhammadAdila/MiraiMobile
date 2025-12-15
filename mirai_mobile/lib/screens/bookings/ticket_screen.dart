import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mirai_mobile/models/booking_model.dart';
import 'package:mirai_mobile/screens/bookings/payment_proof_upload_screen.dart';
import 'package:mirai_mobile/services/api_service.dart';
import 'package:mirai_mobile/utils/constants.dart';

class TicketScreen extends StatefulWidget {
  final int bookingId;

  const TicketScreen({super.key, required this.bookingId});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  BookingModel? booking;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    try {
      setState(() => isLoading = true);
      booking = await ApiService().getBookingDetail(widget.bookingId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat booking: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || booking == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  gradient: AppConstants.primaryGradient,
                ),
                child: Column(
                  children: [
                    Text(
                      AppConstants.eventName,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // QR Code or Status Info
                    if (booking!.isConfirmed) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              '${AppConstants.apiBaseUrl}/api/v1/bookings/${booking!.id}/qr',
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
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ] else if (booking!.isWaitingApproval || booking!.isPending) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.hourglass_top,
                              size: 48,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              booking!.isPending
                                  ? 'Bukti pembayaran bisa di-upload'
                                  : 'Bukti pembayaran telah dikirim',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (booking!.isWaitingApproval)
                              const SizedBox(height: 8),
                            if (booking!.isWaitingApproval)
                              const Text(
                                'Menunggu verifikasi dari admin',
                                textAlign: TextAlign.center,
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
                    Text('Detail Booking', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _DetailRow(label: 'Booking Code', value: booking!.bookingCode ?? 'N/A'),
                    _DetailRow(label: 'Jenis Tiket', value: booking!.ticketTypeName ?? '-'),
                    _DetailRow(label: 'Jumlah', value: '${booking!.quantity}x Tiket'),
                    _DetailRow(label: 'Total Harga', value: booking!.formattedPrice, valueColor: AppConstants.primaryPurple),
                    _DetailRow(
                      label: 'Status Pembayaran',
                      value: booking!.statusText,
                      valueColor: booking!.isConfirmed
                          ? Colors.green
                          : booking!.isPending
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Upload Payment Proof Button
            if (booking!.canUpload) ...[
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentProofUploadScreen(
                        bookingId: booking!.id,
                        bookingCode: booking!.bookingCode!,
                      ),
                    ),
                  );

                  if (result == true) {
                    await _loadBooking(); // 🔹 Refresh booking data otomatis
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Upload Bukti Pembayaran'),
              ),
            ] else if (booking!.isWaitingApproval) ...[
              ElevatedButton(
                onPressed: null,
                child: const Text('Menunggu Verifikasi Admin'),
              ),
            ],

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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppConstants.primaryCyan),
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
          Expanded(flex: 2, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
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
