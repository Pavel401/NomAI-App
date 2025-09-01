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

final FirebaseUserRepo _userRepository = FirebaseUserRepo();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  var remoteConfigService = await RemoteConfigService.getInstance();
  await remoteConfigService!.initialise();
  debugPrint("Initialized Remote Config");
  configLoading();
  setupRegistry();

  Bloc.observer = SimpleBlocObserver();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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

          defaultTransition: getx.Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              if (state.status == AuthenticationStatus.authenticated) {
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
