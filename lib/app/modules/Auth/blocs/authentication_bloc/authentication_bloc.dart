import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turfit/app/models/Auth/user_repo.dart';
import 'package:turfit/app/modules/DashBoard/view/home_screen.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  late final StreamSubscription<User?> _userSubscription;

  AuthenticationBloc({required this.userRepository})
      : super(const AuthenticationState.unknown()) {
    _userSubscription = userRepository.user.listen((user) {
      add(AuthenticationUserChanged(user));
    });

    on<AuthenticationUserChanged>((event, emit) {
      if (event.user != null) {
        emit(AuthenticationState.authenticated(event.user!));
        // Navigate to HomeScreen
        navigateToHomeScreen();
      } else {
        emit(const AuthenticationState.unauthenticated());
      }
    });

    on<GoogleSignInRequested>((event, emit) async {
      try {
        await userRepository.signInWithGoogle();
      } catch (e) {
        // Handle error (e.g., show a message to the user)
        print("Error during Google Sign-In: $e");
      }
    });
  }

  void navigateToHomeScreen() {
    // Use a global key to access the navigator
    final navigatorKey = GlobalKey<NavigatorState>();
    if (navigatorKey.currentState != null) {
      Navigator.of(navigatorKey.currentContext!).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
