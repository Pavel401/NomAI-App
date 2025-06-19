import 'package:equatable/equatable.dart';
import 'package:NomAi/app/models/Auth/user.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserModel extends UserEvent {
  final String uid;

  const LoadUserModel(this.uid);

  @override
  List<Object?> get props => [uid];
}

class UpdateUserModel extends UserEvent {
  final UserModel userModel;

  const UpdateUserModel(this.userModel);

  @override
  List<Object?> get props => [userModel];
}
