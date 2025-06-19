import 'package:equatable/equatable.dart';
import 'package:NomAi/app/models/Auth/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel userModel;

  const UserLoaded(this.userModel);

  @override
  List<Object?> get props => [userModel];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
