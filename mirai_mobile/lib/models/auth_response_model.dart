import 'package:mirai_mobile/models/user_model.dart';

class AuthResponseModel {
  final bool success;
  final String message;
  final UserModel? user;
  final String? token;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return AuthResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: data != null && data['user'] != null
          ? UserModel.fromJson(data['user'])
          : null,
      token: data != null ? data['token'] : null,
    );
  }
}
