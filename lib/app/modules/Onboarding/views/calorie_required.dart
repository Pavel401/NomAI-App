import 'dart:async';

import 'package:flutter/material.dart';
import 'package:turfit/app/models/Auth/user.dart';
import 'package:turfit/app/utility/user_utility.dart';

class DailyCalorieRequired extends StatefulWidget {
  final UserBasicInfo userBasicInfo;

  DailyCalorieRequired({
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

    // Set up animation controller for fade-in effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    // Start calculation and progress simulation
    _startCalculation();
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startCalculation() {
    // Simulate progress for 5 seconds
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_progress < 1.0) {
          _progress += 0.01;
        } else {
          _timer.cancel();
          _isCalculating = false;
          // Start fade-in animation for results
          _animationController.forward();
        }
      });
    });

    // Actually calculate the nutrition (this will be fast in reality,
    // but we'll still show the progress bar for UX purposes)
    _calculateNutrition();
  }

  void _calculateNutrition() {
    // Extract user info from UserBasicInfo object
    final user = widget.userBasicInfo;

    double height = double.parse(user.currentHeight!);

    double weight = double.parse(user.currentWeight!);

    double targetWeight = double.parse(user.desiredWeight!);

    // Calculate nutrition using our utility class
    _userMacros = UserUtility.calculateUserNutrition(
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
          const Text(
            "We're creating your personalized plan",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 10),
                Text(
                  "${(_progress * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  _getProgressMessage(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
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
      return "Analyzing your body metrics...";
    } else if (_progress < 0.6) {
      return "Calculating your nutritional needs...";
    } else if (_progress < 0.9) {
      return "Finalizing your personalized plan...";
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
            Center(
              child: Text(
                "Your Personalized Nutrition Plan",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                _getHealthModeText(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),

            // Daily calorie container
            _buildInfoCard(
              title: "Daily Calories",
              value: "${macros.calories}",
              unit: "kcal",
              icon: Icons.local_fire_department,
              color: Colors.deepOrange,
              description:
                  "Your daily calorie target based on your goals and activity level",
            ),

            const SizedBox(height: 30),

            // Macronutrient breakdown
            const Text(
              "Macronutrient Breakdown",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
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
                    Colors.red.shade400,
                    _calculatePercentage(macros.protein * 4, macros.calories),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMacroCard(
                    "Carbs",
                    macros.carbs,
                    "g",
                    Colors.blue.shade400,
                    _calculatePercentage(macros.carbs * 4, macros.calories),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMacroCard(
                    "Fat",
                    macros.fat,
                    "g",
                    Colors.amber.shade400,
                    _calculatePercentage(macros.fat * 9, macros.calories),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Additional recommendations
            const Text(
              "Additional Recommendations",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildRecommendationCard(
                    "Water Intake",
                    macros.water,
                    "ml",
                    Icons.water_drop,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildRecommendationCard(
                    "Fiber",
                    macros.fiber,
                    "g",
                    Icons.grass,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Next button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the next screen or save the plan
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
        return "Personalized Nutrition Plan";
    }
  }

  double _calculatePercentage(int macroCalories, int totalCalories) {
    return macroCalories / totalCalories;
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 50,
            color: Colors.white,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
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
    Color color,
    double percentage,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                "${(percentage * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeWidth: 10,
                ),
              ),
              Column(
                children: [
                  Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: color.withOpacity(0.7),
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
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 14,
                        color: color.withOpacity(0.7),
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
