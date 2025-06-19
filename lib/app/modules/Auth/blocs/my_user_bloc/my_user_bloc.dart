import 'package:bloc/bloc.dart';

import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_event.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_state.dart';
import 'package:NomAi/app/repo/firebase_user_repo.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirebaseUserRepo userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<LoadUserModel>((event, emit) async {
      emit(UserLoading());
      try {
        final userModel = await userRepository.getUserById(event.uid);
        emit(UserLoaded(userModel));
      } catch (e) {
        emit(UserError("Failed to load user data: ${e.toString()}"));
      }
    });

    on<UpdateUserModel>((event, emit) async {
      emit(UserLoading());
      try {
        await userRepository.updateUserData(event.userModel);
        emit(UserLoaded(event.userModel));
      } catch (e) {
        emit(UserError("Failed to update user data: ${e.toString()}"));
      }
    });
  }
}
