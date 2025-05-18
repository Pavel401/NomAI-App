import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turfit/app/constants/colors.dart';
import 'package:turfit/app/models/Auth/user.dart';
import 'package:turfit/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:turfit/app/modules/Auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:turfit/app/modules/Auth/views/sign_in_screen.dart';
import 'package:turfit/app/utility/user_utility.dart';

class DailyCalorieRequired extends StatefulWidget {
  final UserBasicInfo userBasicInfo;

  const DailyCalorieRequired({
    super.key,
    required this.userBasicInfo,
  });

  @override
  State<DailyCalorieRequired> createState() => _DailyCalorieRequiredState();
}

class _DailyCalorieRequiredState extends State<DailyCalorieRequired>
    with SingleTickerProviderStateMixin {
  bool _isCalculating = true;
  double _progress = 0.0;
  late Timer _timer;
  UserMacros? _userMacros;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _startCalculation();
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startCalculation() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_progress < 1.0) {
          _progress += 0.01;
        } else {
          _timer.cancel();
          _isCalculating = false;
          _animationController.forward();
        }
      });
    });

    _calculateNutrition();
  }

  void _calculateNutrition() {
    final user = widget.userBasicInfo;
    double height = user.currentHeight!;
    double weight = user.currentWeight!;
    double targetWeight = user.desiredWeight!;

    _userMacros = EnhancedUserNutrition.calculateScientificNutrition(
      user.selectedGender,
      user.birthDate,
      height,
      weight,
      user.selectedPace,
      targetWeight,
      user.selectedGoal,
      user.selectedActivityLevel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealAIColors.switchWhiteColor,
      body: SafeArea(
        child: _isCalculating ? _buildCalculatingView() : _buildResultsView(),
      ),
    );
  }

  Widget _buildCalculatingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Creating your plan",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: MealAIColors.blackText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: MealAIColors.greyLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    MealAIColors.selectedTile,
                  ),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 10),
                Text(
                  "${(_progress * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MealAIColors.blackText,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  _getProgressMessage(),
                  style: TextStyle(
                    fontSize: 14,
                    color: MealAIColors.blackText.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getProgressMessage() {
    if (_progress < 0.3) {
      return "Analyzing your metrics...";
    } else if (_progress < 0.6) {
      return "Calculating nutritional needs...";
    } else if (_progress < 0.9) {
      return "Finalizing your plan...";
    } else {
      return "Almost ready!";
    }
  }

  Widget _buildResultsView() {
    final macros = _userMacros!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Your Nutrition Plan",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: MealAIColors.blackText,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _getHealthModeText(),
              style: TextStyle(
                fontSize: 16,
                color: MealAIColors.blackText.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 40),

            // Daily calorie container
            _buildInfoCard(
              title: "Daily Calories",
              value: "${macros.calories}",
              unit: "kcal",
            ),

            const SizedBox(height: 30),

            // Macronutrient breakdown
            Text(
              "Macronutrients",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MealAIColors.blackText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMacroCard(
                    "Protein",
                    macros.protein,
                    "g",
                    _calculatePercentage(macros.protein * 4, macros.calories),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildMacroCard(
                    "Carbs",
                    macros.carbs,
                    "g",
                    _calculatePercentage(macros.carbs * 4, macros.calories),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildMacroCard(
                    "Fat",
                    macros.fat,
                    "g",
                    _calculatePercentage(macros.fat * 9, macros.calories),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Additional recommendations
            Text(
              "Recommendations",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MealAIColors.blackText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildRecommendationCard(
                    "Water",
                    macros.water,
                    "ml",
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildRecommendationCard(
                    "Fiber",
                    macros.fiber,
                    "g",
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Next button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  //     FirebaseUserRepo userRepository = FirebaseUserRepo();

                  //  await   userRepository.updateUserData(
                  //         context.read<AuthenticationBloc>().state.user!.uid,
                  //         widget.userBasicInfo);

                  UserBasicInfo updatedUserBasicInfo =
                      widget.userBasicInfo.copyWith(
                    userMacros: _userMacros,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider<SignInBloc>(
                        create: (context) => SignInBloc(
                            userRepository: context
                                .read<AuthenticationBloc>()
                                .userRepository),
                        child: SignInScreen(
                          user: updatedUserBasicInfo,
                        ),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MealAIColors.selectedTile,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MealAIColors.whiteText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getHealthModeText() {
    switch (widget.userBasicInfo.selectedGoal) {
      case HealthMode.weightLoss:
        return "Weight Loss Plan";
      case HealthMode.muscleGain:
        return "Muscle Gain Plan";
      case HealthMode.maintainWeight:
        return "Weight Maintenance Plan";
      default:
        return "Personalized Plan";
    }
  }

  double _calculatePercentage(int macroCalories, int totalCalories) {
    return macroCalories / totalCalories;
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MealAIColors.selectedTile,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            size: 40,
            color: MealAIColors.whiteText,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: MealAIColors.whiteText,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: MealAIColors.whiteText,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 16,
                        color: MealAIColors.whiteText.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(
    String title,
    int value,
    String unit,
    double percentage,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: MealAIColors.lightGreyTile,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: MealAIColors.blackText,
                ),
              ),
              Text(
                "${(percentage * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: MealAIColors.blackText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: CircularProgressIndicator(
                  value: percentage,
                  backgroundColor: MealAIColors.stepperColor,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(MealAIColors.selectedTile),
                  strokeWidth: 8,
                ),
              ),
              Column(
                children: [
                  Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MealAIColors.blackText,
                    ),
                  ),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: MealAIColors.blackText.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    String title,
    int value,
    String unit,
  ) {
    IconData icon = title == "Water" ? Icons.water_drop : Icons.grass;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: MealAIColors.lightGreyTile,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MealAIColors.switchWhiteColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: MealAIColors.blackText,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MealAIColors.blackText,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MealAIColors.blackText,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 14,
                        color: MealAIColors.blackText.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
