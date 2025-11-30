import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mirai_mobile/models/user_model.dart';
import 'package:mirai_mobile/utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Management
  Future<void> saveToken(String token) async {
    await _prefs?.setString(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _prefs?.getString(AppConstants.tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs?.remove(AppConstants.tokenKey);
  }

  bool hasToken() {
    return _prefs?.getString(AppConstants.tokenKey) != null;
  }

  // User Data Management
  Future<void> saveUser(UserModel user) async {
    final userJson = json.encode(user.toJson());
    await _prefs?.setString(AppConstants.userKey, userJson);
  }

  UserModel? getUser() {
    final userJson = _prefs?.getString(AppConstants.userKey);
    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }
    return null;
  }

  Future<void> removeUser() async {
    await _prefs?.remove(AppConstants.userKey);
  }

  // Clear All Data
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
