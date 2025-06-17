class User {
  final int id;
  final String username;
  final String email;
  final bool isAdmin;
  final String? token;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.isAdmin = false,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      isAdmin: json['isAdmin'] ?? false,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'isAdmin': isAdmin,
      'token': token,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    bool? isAdmin,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
      token: token ?? this.token,
    );
  }
}
