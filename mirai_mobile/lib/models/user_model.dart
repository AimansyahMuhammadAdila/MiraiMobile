class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role; // 'user' or 'admin'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'user',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle both String and int for id
    int userId;
    if (json['id'] is String) {
      userId = int.parse(json['id']);
    } else {
      userId = json['id'] as int;
    }

    return UserModel(
      id: userId,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }

  // Check if user is admin
  bool get isAdmin => role == 'admin';

  // Check if user is regular user
  bool get isUser => role == 'user';
}
