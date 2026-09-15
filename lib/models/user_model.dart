class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final int pointsBalance;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.pointsBalance = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'nasabah',
      pointsBalance: json['points_balance'] is int
          ? json['points_balance']
          : int.tryParse(json['points_balance']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'points_balance': pointsBalance,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isPetugas => role == 'petugas';
  bool get isPetugasOrAdmin => role == 'petugas' || role == 'admin';
}

class LoginResult {
  final String token;
  final String tokenType;
  final int expiresIn;
  final UserModel user;

  LoginResult({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: json['token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'Bearer',
      expiresIn: json['expires_in'] is int
          ? json['expires_in']
          : int.tryParse(json['expires_in']?.toString() ?? '0') ?? 0,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}
