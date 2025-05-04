class User {
  final String id;
  final String role;
  final String? userId;

  User({required this.id, required this.role, required this.userId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['\$id'],
      role: json['role'],
      userId: json['userId'] ?? 'No userId available',
    );
  }

  User copyWith({
    String? id,
    String? role,
    String? userId,
  }) {
    return User(
      id: id ?? this.id,
      role: role ?? this.role,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() => {'role': role, 'userId': userId};
}
