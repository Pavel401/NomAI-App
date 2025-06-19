import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as getx;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_event.dart';
import 'package:NomAi/app/modules/Auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:NomAi/app/modules/DashBoard/view/dashboard.dart';
import 'package:NomAi/app/modules/Onboarding/views/onboarding_home.dart';
import 'package:NomAi/app/providers/remoteconfig.dart';
import 'package:NomAi/app/providers/theme_provider.dart';
import 'package:NomAi/app/repo/firebase_user_repo.dart';
import 'package:NomAi/app/utility/registry_service.dart';
import 'package:NomAi/app/utility/simple_bloc_observer.dart';

// Pre-initialize repository for faster startup
final FirebaseUserRepo _userRepository = FirebaseUserRepo();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var remoteConfigService = await RemoteConfigService.getInstance();
  await remoteConfigService!.initialise();
  debugPrint("Initialized Remote Config");
  configLoading();
  setupRegistry();

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
        // BlocProvider<UserBloc>(
        //   create: (context) {
        //     final userBloc = UserBloc(userRepository: _userRepository);
        //     // Listen to auth state changes to load user data when authenticated
        //     context.read<AuthenticationBloc>().stream.listen((authState) {
        //       if (authState.status == AuthenticationStatus.authenticated &&
        //           authState.user != null) {
        //         userBloc.add(LoadUserModel(authState.user!.uid));
        //       }
        //     });
        //     return userBloc;
        //   },
        // ),
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

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 40.0
    ..radius = 10.0
    ..progressColor = MealAIColors.switchWhiteColor
    ..backgroundColor = MealAIColors.blackText.withOpacity(0.8)
    ..indicatorColor = MealAIColors.switchWhiteColor
    ..textColor = MealAIColors.switchWhiteColor
    ..maskColor = MealAIColors.blackText.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Sizer(
      builder: (context, orientation, deviceType) {
        return getx.GetMaterialApp(
          builder: EasyLoading.init(),

          title: 'Firebase Auth',

          defaultTransition: getx.Transition
              .fadeIn, // You can change this to fade, zoom, downToUp, etc.
          transitionDuration: const Duration(milliseconds: 300), // Optional
          debugShowCheckedModeBanner: false, // Remove banner for performance
          theme: themeProvider.lightTheme,
          // darkTheme: themeProvider.darkTheme,
          // themeMode:
          //     themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            // Add buildWhen to only rebuild when authentication status changes
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              if (state.status == AuthenticationStatus.authenticated) {
                // Lazily provide SignInBloc only when needed
                return MultiBlocProvider(
                  providers: [
                    BlocProvider<SignInBloc>(
                      create: (context) => SignInBloc(
                        userRepository: _userRepository,
                      ),
                    ),
                    BlocProvider<UserBloc>(
                      create: (context) => UserBloc(
                        userRepository: _userRepository,
                      )..add(LoadUserModel(state.user!.uid)),
                    ),
                  ],
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

class CustomAnimation extends EasyLoadingAnimation {
  CustomAnimation();

  @override
  Widget buildWidget(
    Widget child,
    AnimationController controller,
    AlignmentGeometry alignment,
  ) {
    return Opacity(
      opacity: controller.value,
      child: RotationTransition(
        turns: controller,
        child: child,
      ),
    );
  }
}
