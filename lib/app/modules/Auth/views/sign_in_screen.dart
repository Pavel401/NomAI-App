import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:NomAi/app/components/dialogs.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/constants/constants.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/modules/Auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:NomAi/app/modules/DashBoard/view/dashboard.dart';
import 'package:NomAi/app/repo/firebase_user_repo.dart';

class SignInScreen extends StatefulWidget {
  final UserBasicInfo? user;
  const SignInScreen({super.key, this.user});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool signInRequired = false;
  String? _errorMsg;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          print('Sign In Success');
          setState(() {
            signInRequired = false;
          });
          final FirebaseUserRepo _userRepository = FirebaseUserRepo();

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => SignInBloc(
                  userRepository: _userRepository,
                ),
                child: const HomeScreen(),
              ),
            ),
            (route) =>
                false, // This predicate ensures all previous routes are removed
          );
        } else if (state is SignInProcess) {
          setState(() {
            signInRequired = true;
          });
        } else if (state is SignInFailure) {
          setState(() {
            signInRequired = false;
            _errorMsg = 'Sign in failed';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMsg ?? 'Sign in failed'),
              backgroundColor: MealAIColors.grey,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: MealAIColors.blackText.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_dining,
                    size: 70,
                    color: MealAIColors.blackText,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Welcome to ${AppInfo.appName}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: MealAIColors.blackText,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "${AppInfo.appDescription}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 70),
                !signInRequired
                    ? Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context
                                .read<SignInBloc>()
                                .add(GoogleSignInRequested(widget.user!));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: MealAIColors.blackText,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            elevation: 1,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset("assets/svg/google.svg",
                                  width: 24),
                              SizedBox(width: 16),
                              Text(
                                "Continue with Google",
                                style: TextStyle(
                                  color: MealAIColors.blackText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          color: MealAIColors.blackText,
                        ),
                      ),
                SizedBox(height: 20),
                Text(
                  "By signing in, you agree to our Terms & Privacy Policy",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
