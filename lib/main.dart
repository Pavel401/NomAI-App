import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:turfit/app/models/Auth/user_repo.dart';
import 'package:turfit/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:turfit/app/modules/Auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:turfit/app/modules/DashBoard/view/home_screen.dart';
import 'package:turfit/app/modules/Onboarding/views/onboarding_home.dart';
import 'package:turfit/app/providers/theme_provider.dart';
import 'package:turfit/app/repo/firebase_user_repo.dart';
import 'package:turfit/app/utility/simple_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Bloc.observer = SimpleBlocObserver();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // BlocProvider<SignInBloc>(
        //   create: (context) => SignInBloc(userRepository: FirebaseUserRepo()),
        // ),
      ],
      child: MyApp(FirebaseUserRepo()),
    ),
  );
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  const MyApp(this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthenticationBloc>(
      create: (context) => AuthenticationBloc(userRepository: userRepository),
      child: const MyAppView(),
    );
  }
}

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        title: 'Firebase Auth',
        debugShowCheckedModeBanner: true,
        theme: themeProvider.lightTheme,
        darkTheme: themeProvider.darkTheme,
        themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state.status == AuthenticationStatus.authenticated) {
              return BlocProvider(
                create: (context) => SignInBloc(
                    userRepository:
                        context.read<AuthenticationBloc>().userRepository),
                child: BlocListener<SignInBloc, SignInState>(
                  listener: (context, signInState) {
                    if (signInState is SignInSuccess) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    }
                  },
                  child: const HomeScreen(),
                ),
              );
            } else {
              return const OnboardingHome();
            }
          },
        ),
      );
    });
  }
}
