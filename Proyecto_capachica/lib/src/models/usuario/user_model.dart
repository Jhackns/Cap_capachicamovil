import 'package:equatable/equatable.dart';

enum UserRole { turista, administrador }

class User extends Equatable {
  final String id;
  final String nombre;
  final String email;
  final UserRole rol;

  const User({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  @override
  List<Object?> get props => [id, nombre, email, rol];

  // Placeholder for JSON serialization if needed later
  // Map<String, dynamic> toJson() => {
  //   'id': id,
  //   'nombre': nombre,
  //   'email': email,
  //   'rol': rol.toString(),
  // };

  // Placeholder for JSON deserialization if needed later
  // factory User.fromJson(Map<String, dynamic> json) => User(
  //   id: json['id'],
  //   nombre: json['nombre'],
  //   email: json['email'],
  //   rol: UserRole.values.firstWhere((e) => e.toString() == json['rol']),
  // );
}
