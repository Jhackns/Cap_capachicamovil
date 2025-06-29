abstract class UsersEvent {}

class LoadUsers extends UsersEvent {}

class CreateUser extends UsersEvent {
  final Map<String, dynamic> userData;
  CreateUser(this.userData);
}

class UpdateUser extends UsersEvent {
  final int userId;
  final Map<String, dynamic> userData;
  UpdateUser(this.userId, this.userData);
}

class DeleteUser extends UsersEvent {
  final int userId;
  DeleteUser(this.userId);
}

class ActivateUser extends UsersEvent {
  final int userId;
  ActivateUser(this.userId);
}

class DeactivateUser extends UsersEvent {
  final int userId;
  DeactivateUser(this.userId);
}

class FilterUsers extends UsersEvent {
  final String searchQuery;
  final String status;
  final String role;
  FilterUsers({required this.searchQuery, required this.status, required this.role});
} 