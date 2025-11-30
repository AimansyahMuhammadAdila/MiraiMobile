import 'package:flutter/material.dart';
import 'package:mirai_mobile/models/ticket_type_model.dart';
import 'package:mirai_mobile/services/api_service.dart';

class TicketProvider with ChangeNotifier {
  final _apiService = ApiService();

  List<TicketTypeModel> _tickets = [];
  bool _isLoading = false;
  String? _error;

  List<TicketTypeModel> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTickets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tickets = await _apiService.getTickets();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal mengambil data tiket: ${e.toString()}';
      notifyListeners();
    }
  }

  TicketTypeModel? getTicketById(int id) {
    try {
      return _tickets.firstWhere((ticket) => ticket.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
