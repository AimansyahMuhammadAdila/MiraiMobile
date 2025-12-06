import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mirai_mobile/services/api_service.dart';
import 'package:mirai_mobile/utils/constants.dart';
import 'package:mirai_mobile/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mirai_mobile/screens/admin/payment_verification_screen.dart';
import 'package:mirai_mobile/screens/admin/user_management_screen.dart';
import 'package:mirai_mobile/screens/admin/ticket_management_screen.dart';
import 'package:mirai_mobile/screens/auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {
    'total_bookings': 0,
    'pending_payments': 0,
    'total_revenue': 0,
    'total_users': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final response = await _apiService.getDashboardStats();
      if (response.success && mounted) {
        setState(() {
          _stats = response.data['overview'] ?? _stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat statistik: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Verify user is admin
    if (user == null || !user.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel - MiraiFest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
              if (index == 0) {
                _loadStats();
              }
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppConstants.backgroundDark,
            selectedIconTheme: const IconThemeData(
              color: AppConstants.primaryPurple,
            ),
            selectedLabelTextStyle: const TextStyle(
              color: AppConstants.primaryPurple,
              fontWeight: FontWeight.bold,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.payment),
                label: Text('Verifikasi'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.confirmation_number),
                label: Text('Tickets'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),

          // Main Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return const PaymentVerificationScreen();
      case 2:
        return const UserManagementScreen();
      case 3:
        return const TicketManagementScreen();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Overview',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),

            // Statistics Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio:
                  1.5, // Made cards taller to prevent bottom overflow
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(
                  'Total Bookings',
                  _stats['total_bookings'].toString(),
                  Icons.shopping_cart,
                  AppConstants.primaryPurple,
                ),
                _buildStatCard(
                  'Pending Payments',
                  _stats['pending_payments'].toString(),
                  Icons.pending_actions,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Total Revenue',
                  _formatCurrency(_stats['total_revenue']),
                  Icons.attach_money,
                  Colors.green,
                ),
                _buildStatCard(
                  'Total Users',
                  _stats['total_users'].toString(),
                  Icons.people,
                  AppConstants.primaryCyan,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Verify Payments'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Manage Users'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Ticket Type'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: color, size: 28),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp 0';
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(double.tryParse(amount.toString()) ?? 0);
  }
}
