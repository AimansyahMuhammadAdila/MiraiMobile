import 'package:flutter/material.dart';
import 'package:mirai_mobile/models/booking_model.dart';
import 'package:mirai_mobile/services/api_service.dart';

class BookingProvider with ChangeNotifier {
  final _apiService = ApiService();

  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String? _error;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get error => _error;

  Future<void> fetchBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _apiService.getBookings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal mengambil data booking: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> createBooking({
    required int ticketTypeId,
    required int quantity,
  }) async {
    _isCreating = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createBooking(
        ticketTypeId: ticketTypeId,
        quantity: quantity,
      );

      _isCreating = false;

      if (response['success'] == true) {
        // Refresh bookings list
        await fetchBookings();
        return true;
      } else {
        _error = response['message'] ?? 'Gagal membuat booking';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isCreating = false;
      _error = 'Gagal membuat booking: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  BookingModel? getBookingById(int id) {
    try {
      return _bookings.firstWhere((booking) => booking.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
