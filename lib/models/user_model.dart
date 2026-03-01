// User Model - Authentication & Role Management
class UserModel {
  final String id;
  final String name;
  final String email;
  final String password; // hashed or plain for demo
  final String role; // 'admin' or 'staff'
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
        role: json['role'] ?? 'staff',
        isActive: json['isActive'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'isActive': isActive,
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    bool? isActive,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
      );
}
