class User {
  final int id;
  final String username;
  final String email;
  final String? phone;
  final String? googleId;
  final String? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.googleId,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      googleId: json['google_id'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'google_id': googleId,
      'created_at': createdAt,
    };
  }
}
