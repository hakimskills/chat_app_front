class UserModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final bool emailVerified;
  final String? phoneNumber;
  final String? avatar;
  final String? bio;
  final DateTime? lastSeenAt;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.emailVerified,
    this.phoneNumber,
    this.avatar,
    this.bio,
    this.lastSeenAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      emailVerified: json['email_verified'] as bool? ?? false,
      phoneNumber: json['phone_number'] as String?,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.tryParse(json['last_seen_at'] as String)
          : null,
    );
  }
}
