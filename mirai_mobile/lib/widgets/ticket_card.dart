import 'package:flutter/material.dart';
import 'package:mirai_mobile/models/ticket_type_model.dart';
import 'package:mirai_mobile/utils/constants.dart';

class TicketCard extends StatelessWidget {
  final TicketTypeModel ticket;
  final VoidCallback onTap;

  const TicketCard({super.key, required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: InkWell(
        onTap: ticket.isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ticket.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ticket.isAvailable
                          ? AppConstants.primaryCyan.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ticket.isAvailable ? 'Tersedia' : 'Habis',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ticket.isAvailable
                            ? AppConstants.primaryCyan
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              if (ticket.description != null)
                Text(
                  ticket.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 16),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harga',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        ticket.formattedPrice,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppConstants.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Quota
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Sisa Kuota',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${ticket.remainingQuota} / ${ticket.quota}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
