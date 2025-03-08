import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:turfit/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:turfit/app/modules/Auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:turfit/app/modules/DashBoard/view/dashboard.dart';
import 'package:turfit/app/modules/Onboarding/views/onboarding_home.dart';
import 'package:turfit/app/providers/theme_provider.dart';
import 'package:turfit/app/repo/firebase_user_repo.dart';
import 'package:turfit/app/utility/simple_bloc_observer.dart';

// Pre-initialize repository for faster startup
final FirebaseUserRepo _userRepository = FirebaseUserRepo();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Configure Bloc observer in release mode only if needed
  // This reduces startup overhead
  Bloc.observer = SimpleBlocObserver();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Pre-create the AuthenticationBloc at app startup
        BlocProvider<AuthenticationBloc>(
            create: (context) =>
                AuthenticationBloc(userRepository: _userRepository)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyAppView();
  }
}

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Firebase Auth',
          debugShowCheckedModeBanner: false, // Remove banner for performance
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            // Add buildWhen to only rebuild when authentication status changes
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              if (state.status == AuthenticationStatus.authenticated) {
                // Lazily provide SignInBloc only when needed
                return BlocProvider(
                  create: (context) => SignInBloc(
                    userRepository: _userRepository,
                  ),
                  // Remove the BlocListener which is causing an extra rendering cycle
                  child: const HomeScreen(),
                );
              }
              if (state.status == AuthenticationStatus.unauthenticated) {
                return const OnboardingHome();
              }
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
