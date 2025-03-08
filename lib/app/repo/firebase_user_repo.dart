import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:turfit/app/models/Auth/user.dart';
import 'package:turfit/app/models/Auth/user_repo.dart';

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final usersCollection = FirebaseFirestore.instance.collection('users');

  FirebaseUserRepo({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser;
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserModel> signUp(UserModel myUser, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: myUser.email, password: password);

      myUser = myUser.copyWith(userId: user.user!.uid);

      return myUser;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> setUserData(UserModel myUser) async {
    try {
      await usersCollection.doc(myUser.userId).set(myUser.toEntity());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      log('Starting Google sign-in...');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        log('Google sign-in canceled');
        throw Exception('Google sign-in canceled');
      }

      log('Google sign-in successful: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        log('Google auth token retrieval failed');
        throw Exception('Google authentication tokens missing');
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        log('Firebase user is null after Google sign-in');
        throw Exception('Firebase authentication failed');
      }

      log('Firebase sign-in successful: ${user.email}');
      return UserModel(
        userId: user.uid,
        email: user.email!,
        name: user.displayName ?? 'Unknown User',
        photoUrl: user.photoURL ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      log('Google sign-in error: $e');
      rethrow;
    }
  }

  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }
}
