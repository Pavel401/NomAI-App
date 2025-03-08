import 'package:firebase_auth/firebase_auth.dart';
import 'package:turfit/app/models/Auth/user.dart';

abstract class UserRepository {
  Stream<User?> get user;

  Future<UserModel> signUp(UserModel myUser, String password);

  Future<void> setUserData(UserModel user);

  Future<void> signIn(String email, String password);

  Future<void> logOut();

  Future<UserModel> signInWithGoogle();
}
