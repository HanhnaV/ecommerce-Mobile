  class GenderType {
  static const String male = 'MALE';
  static const String female = 'FEMALE';
}

class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final String? phone;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool accountVerified;
  final DateTime? createdAt;
  final String? gender;
  final DateTime? dateOfBirth;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.phoneNumber,
    this.avatarUrl,
    this.accountVerified = false,
    this.createdAt,
    this.gender,
    this.dateOfBirth,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
      phone: json['phone'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      accountVerified: json['accountVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth'] as String) : null,
    );
  }

  factory UserModel.fromLoginResponse(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['username'] as String? ?? json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
      phone: json['phone'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      accountVerified: json['accountVerified'] as bool? ?? false,
      createdAt: null,
      gender: null,
      dateOfBirth: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'phone': phone,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'accountVerified': accountVerified,
      'createdAt': createdAt?.toIso8601String(),
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String().split('T')[0],
    };
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? fullName,
    String? role,
    String? phone,
    String? phoneNumber,
    String? avatarUrl,
    bool? accountVerified,
    DateTime? createdAt,
    String? gender,
    DateTime? dateOfBirth,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      accountVerified: accountVerified ?? this.accountVerified,
      createdAt: createdAt ?? this.createdAt,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}
