abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> filteredUsers;
  UsersLoaded({required this.users, required this.filteredUsers});
}

class UsersError extends UsersState {
  final String message;
  UsersError(this.message);
}

class UserOperationSuccess extends UsersState {
  final String message;
  UserOperationSuccess(this.message);
}

class UserOperationError extends UsersState {
  final String message;
  UserOperationError(this.message);
} 