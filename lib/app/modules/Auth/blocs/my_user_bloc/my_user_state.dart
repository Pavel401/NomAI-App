part of 'my_user_bloc.dart';

sealed class MyUserState extends Equatable {
  const MyUserState();
  
  @override
  List<Object> get props => [];
}

final class MyUserInitial extends MyUserState {}
