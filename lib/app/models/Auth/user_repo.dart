import 'package:firebase_auth/firebase_auth.dart';
import 'package:turfit/app/models/Auth/user.dart';

abstract class UserRepository {
  Stream<User?> get user;

  Future<MyUser> signUp(MyUser myUser, String password);

  Future<void> setUserData(MyUser user);

  Future<void> signIn(String email, String password);

  Future<void> logOut();

  Future<void> signInWithGoogle();
}
