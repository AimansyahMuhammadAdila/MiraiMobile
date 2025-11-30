import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mirai_mobile/models/ticket_type_model.dart';
import 'package:mirai_mobile/providers/booking_provider.dart';
import 'package:mirai_mobile/providers/ticket_provider.dart';
import 'package:mirai_mobile/utils/constants.dart';
import 'package:mirai_mobile/widgets/custom_button.dart';

class TicketDetailScreen extends StatefulWidget {
  final TicketTypeModel ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  int _quantity = 1;

  void _incrementQuantity() {
    if (_quantity < widget.ticket.remainingQuota && _quantity < 10) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  Future<void> _handlePurchase() async {
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);

    final success = await bookingProvider.createBooking(
      ticketTypeId: widget.ticket.id,
      quantity: _quantity,
    );

    if (success && mounted) {
      // Refresh tickets to update quota
      await ticketProvider.fetchTickets();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking berhasil! QR Code telah digenerate.'),
          backgroundColor: Colors.green,
        ),
      );

      // Go back and navigate to bookings tab
      Navigator.of(context).pop();
      // Note: In full implementation, would navigate to booking detail or switch tab
    } else if (bookingProvider.error != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(bookingProvider.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.ticket.price * _quantity;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tiket')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ticket Name
                  Text(
                    widget.ticket.name,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Text(
                    widget.ticket.formattedPrice,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppConstants.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Availability
                  Row(
                    children: [
                      Icon(
                        widget.ticket.isAvailable
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        color: widget.ticket.isAvailable
                            ? AppConstants.primaryCyan
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.ticket.isAvailable
                            ? 'Tersedia (${widget.ticket.remainingQuota} tersisa)'
                            : 'Sold Out',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Divider(),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Yang Anda Dapatkan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),

                  if (widget.ticket.description != null)
                    ...widget.ticket.description!.split(',').map((benefit) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 20,
                              color: AppConstants.primaryCyan,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                benefit.trim(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 24),
                  Divider(),
                  const SizedBox(height: 24),

                  // Quantity Selector
                  if (widget.ticket.isAvailable) ...[
                    Text(
                      'Jumlah Tiket',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        IconButton(
                          onPressed: _decrementQuantity,
                          icon: const Icon(Icons.remove_circle_outline),
                          iconSize: 32,
                          color: AppConstants.primaryPurple,
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppConstants.primaryPurple,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_quantity',
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: _incrementQuantity,
                          icon: const Icon(Icons.add_circle_outline),
                          iconSize: 32,
                          color: AppConstants.primaryPurple,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Purchase Bar
          if (widget.ticket.isAvailable)
            Container(
              decoration: BoxDecoration(
                color: AppConstants.cardDark,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Harga',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Rp ${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: AppConstants.primaryPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Consumer<BookingProvider>(
                      builder: (context, bookingProvider, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'Beli Tiket',
                            onPressed: _handlePurchase,
                            isLoading: bookingProvider.isCreating,
                            icon: Icons.shopping_cart,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
