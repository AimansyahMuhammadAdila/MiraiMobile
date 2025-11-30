import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mirai_mobile/providers/booking_provider.dart';
import 'package:mirai_mobile/screens/bookings/ticket_screen.dart';
import 'package:mirai_mobile/utils/constants.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Booking'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookingProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    bookingProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => bookingProvider.fetchBookings(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (bookingProvider.bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 60,
                    color: AppConstants.textGray,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada booking',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Beli tiket sekarang!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await bookingProvider.fetchBookings();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              itemCount: bookingProvider.bookings.length,
              itemBuilder: (context, index) {
                final booking = bookingProvider.bookings[index];

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: AppConstants.paddingMedium,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TicketScreen(booking: booking),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                booking.bookingCode,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              _StatusBadge(status: booking.paymentStatus),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Ticket Info
                          Text(
                            booking.ticketName ?? 'Tiket',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),

                          // Quantity and Price
                          Row(
                            children: [
                              Icon(
                                Icons.confirmation_number,
                                size: 16,
                                color: AppConstants.textGray,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${booking.quantity}x Tiket',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.attach_money,
                                size: 16,
                                color: AppConstants.textGray,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                booking.formattedPrice,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppConstants.primaryPurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Action Button
                          if (booking.isConfirmed)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          TicketScreen(booking: booking),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.qr_code_2, size: 20),
                                label: const Text('Lihat E-Ticket'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color _getColor() {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return AppConstants.textGray;
    }
  }

  String _getText() {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getText(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: _getColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
