import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/models/Auth/user_repo.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final UserRepository _userRepository;

  SignInBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SignInInitial()) {
    on<SignInRequired>((event, emit) async {
      emit(SignInProcess());
      try {
        await _userRepository.signIn(event.email, event.password);
        emit(SignInSuccess());
      } on FirebaseAuthException catch (e) {
        emit(SignInFailure(message: e.code));
      } catch (e) {
        emit(const SignInFailure());
      }
    });
    on<SignOutRequired>((event, emit) async {
      await _userRepository.logOut();
    });

    on<GoogleSignInRequested>((event, emit) async {
      try {
        emit(SignInProcess());

        EasyLoading.show(status: 'Signing in...');
        UserModel model = await _userRepository.signInWithGoogle();

        UserModel nModel = UserModel(
            userId: model.userId,
            email: model.email,
            name: model.name,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            userInfo: event.userBasicInfo,
            photoUrl: model.photoUrl,
            phoneNumber: model.phoneNumber);

        await _userRepository.setUserData(nModel);

        EasyLoading.dismiss();

        emit(SignInSuccess());
      } on FirebaseAuthException catch (e) {
        EasyLoading.dismiss();

        emit(SignInFailure(message: e.code));
      } catch (e) {
        EasyLoading.dismiss();

        emit(const SignInFailure());
      }
    });
  }
}
