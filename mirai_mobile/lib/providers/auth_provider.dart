import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mirai_mobile/models/user_model.dart';
import 'package:mirai_mobile/services/api_service.dart';
import 'package:mirai_mobile/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final _apiService = ApiService();
  final _storage = StorageService();

  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> checkAuthStatus() async {
    if (_storage.hasToken()) {
      _user = _storage.getUser();
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      _isLoading = false;

      if (response.success) {
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          _error = data['message'] ?? 'Terjadi kesalahan pada server';
          // If there are validation errors in 'data', we could append them
          // but for now just showing the main message is better than the exception
        } else {
          _error = 'Terjadi kesalahan: ${e.message}';
        }
      } else {
        _error = 'Gagal mendaftar: ${e.toString()}';
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      _isLoading = false;

      if (response.success && response.user != null && response.token != null) {
        _user = response.user;
        _isAuthenticated = true;

        // Save to storage
        await _storage.saveToken(response.token!);
        await _storage.saveUser(response.user!);

        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          _error = data['message'] ?? 'Terjadi kesalahan pada server';
        } else {
          _error = 'Terjadi kesalahan: ${e.message}';
        }
      } else {
        _error = 'Gagal login: ${e.toString()}';
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore logout API errors
    }

    // Clear local data
    await _storage.clearAll();
    _user = null;
    _isAuthenticated = false;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
