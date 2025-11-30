import 'package:flutter/material.dart';
import 'package:mirai_mobile/services/api_service.dart';
import 'package:mirai_mobile/utils/constants.dart';
import 'package:mirai_mobile/models/ticket_type_model.dart';

class TicketManagementScreen extends StatefulWidget {
  const TicketManagementScreen({super.key});

  @override
  State<TicketManagementScreen> createState() => _TicketManagementScreenState();
}

class _TicketManagementScreenState extends State<TicketManagementScreen> {
  final ApiService _apiService = ApiService();
  List<TicketTypeModel> _tickets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tickets = await _apiService.getTickets();
      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _showTicketDialog([TicketTypeModel? ticket]) async {
    final isEditing = ticket != null;
    final nameController = TextEditingController(text: ticket?.name);
    final descriptionController = TextEditingController(
      text: ticket?.description,
    );
    final priceController = TextEditingController(
      text: ticket?.price.toString().replaceAll('.0', ''),
    );
    final quotaController = TextEditingController(
      text: ticket?.quota.toString(),
    );

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Tipe Tiket' : 'Tambah Tipe Tiket'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Tiket'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Nama wajib diisi'
                      : null,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 2,
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Harga wajib diisi';
                    if (double.tryParse(value) == null)
                      return 'Harga harus angka';
                    return null;
                  },
                ),
                TextFormField(
                  controller: quotaController,
                  decoration: const InputDecoration(labelText: 'Kuota'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Kuota wajib diisi';
                    if (int.tryParse(value) == null) return 'Kuota harus angka';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final data = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'price': double.parse(priceController.text),
                  'quota': int.parse(quotaController.text),
                };

                try {
                  Navigator.pop(context); // Close dialog first

                  // Show loading indicator
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menyimpan data...')),
                    );
                  }

                  bool success;
                  if (isEditing) {
                    success = await _apiService.updateTicketType(
                      ticket.id,
                      data,
                    );
                  } else {
                    success = await _apiService.createTicketType(data);
                  }

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? 'Tiket berhasil diperbarui'
                              : 'Tiket berhasil dibuat',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadTickets();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menyimpan: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: Text(isEditing ? 'Simpan' : 'Buat'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTicket(TicketTypeModel ticket) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tiket'),
        content: Text(
          'Apakah Anda yakin ingin menghapus tiket "${ticket.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _apiService.deleteTicketType(ticket.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tiket berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          _loadTickets();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTickets,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: _tickets.length + 1, // +1 for add button
        itemBuilder: (context, index) {
          if (index == 0) {
            // Add new ticket button
            return Card(
              margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
              color: AppConstants.primaryPurple.withOpacity(0.1),
              child: InkWell(
                onTap: () => _showTicketDialog(),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_circle_outline,
                        color: AppConstants.primaryPurple,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tambah Tipe Tiket Baru',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppConstants.primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final ticket = _tickets[index - 1];
          return Card(
            margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ticket.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showTicketDialog(ticket);
                          } else if (value == 'delete') {
                            _deleteTicket(ticket);
                          }
                        },
                      ),
                    ],
                  ),
                  if (ticket.description != null &&
                      ticket.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      ticket.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.textGray,
                      ),
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          Icons.attach_money,
                          'Rp ${ticket.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoChip(
                          Icons.inventory,
                          '${ticket.remainingQuota}/${ticket.quota}',
                          ticket.remainingQuota > 0
                              ? AppConstants.primaryCyan
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
