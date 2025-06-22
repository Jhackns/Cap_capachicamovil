class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final bool active;
  final String? fotoPerfil;
  final String? country;
  final String? birthDate;
  final String? address;
  final String? gender;
  final String? preferredLanguage;
  final String? lastLogin;
  final String? createdAt;
  final String? updatedAt;
  final List<String> roles;
  final bool isAdmin;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.active = true,
    this.fotoPerfil,
    this.country,
    this.birthDate,
    this.address,
    this.gender,
    this.preferredLanguage,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
    this.roles = const [],
    this.isAdmin = false,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<String> parseRoles(dynamic roles) {
      if (roles == null) return [];
      if (roles is List) {
        return roles.map((role) => role.toString()).toList();
      }
      return [];
    }

    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      active: json['active'] ?? true,
      fotoPerfil: json['foto_perfil'],
      country: json['country'],
      birthDate: json['birth_date'],
      address: json['address'],
      gender: json['gender'],
      preferredLanguage: json['preferred_language'],
      lastLogin: json['last_login'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      roles: parseRoles(json['roles']),
      isAdmin: json['is_admin'] ?? false,
      token: json['token'],
    );
  }

  factory User.fromAuthResponse(Map<String, dynamic> json) {
    List<String> parseRoles(dynamic roles) {
      if (roles == null) return [];
      if (roles is List) {
        return roles.map((role) => role.toString()).toList();
      }
      return [];
    }

    final userData = json['user'] ?? json;
    
    return User(
      id: userData['id'] ?? 0,
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
      phone: userData['phone'],
      active: userData['active'] ?? true,
      fotoPerfil: userData['foto_perfil'],
      country: userData['country'],
      birthDate: userData['birth_date'],
      address: userData['address'],
      gender: userData['gender'],
      preferredLanguage: userData['preferred_language'],
      lastLogin: userData['last_login'],
      createdAt: userData['created_at'],
      updatedAt: userData['updated_at'],
      roles: parseRoles(json['roles']),
      isAdmin: parseRoles(json['roles']).contains('admin'),
      token: json['access_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'active': active,
      'foto_perfil': fotoPerfil,
      'country': country,
      'birth_date': birthDate,
      'address': address,
      'gender': gender,
      'preferred_language': preferredLanguage,
      'last_login': lastLogin,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'roles': roles,
      'is_admin': isAdmin,
      'token': token,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    bool? active,
    String? fotoPerfil,
    String? country,
    String? birthDate,
    String? address,
    String? gender,
    String? preferredLanguage,
    String? lastLogin,
    String? createdAt,
    String? updatedAt,
    List<String>? roles,
    bool? isAdmin,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      active: active ?? this.active,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      country: country ?? this.country,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roles: roles ?? this.roles,
      isAdmin: isAdmin ?? this.isAdmin,
      token: token ?? this.token,
    );
  }

  bool hasRole(String role) {
    return roles.contains(role);
  }

  bool hasAnyRole(List<String> roleList) {
    return roles.any((role) => roleList.contains(role));
  }
}
