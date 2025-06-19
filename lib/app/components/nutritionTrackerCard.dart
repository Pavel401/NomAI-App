import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';

class NutritionTrackerCard extends StatelessWidget {
  final int maximumCalories;
  final int consumedCalories;
  final int burnedCalories;
  final int maximumFat;
  final int consumedFat;
  final int maximumProtein;
  final int consumedProtein;
  final int maximumCarb;
  final int consumedCarb;

  const NutritionTrackerCard({
    Key? key,
    required this.maximumCalories,
    required this.consumedCalories,
    required this.burnedCalories,
    required this.maximumFat,
    required this.consumedFat,
    required this.maximumProtein,
    required this.consumedProtein,
    required this.maximumCarb,
    required this.consumedCarb,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate net calories (consumed - burned)
    int netCalories = consumedCalories - burnedCalories;

    // Calculate remaining calories, ensuring it doesn't go below 0
    int remainingCalories =
        (maximumCalories - netCalories).clamp(0, maximumCalories);

    // Calculate actual remaining calories (can be negative) for better status indication
    int actualRemainingCalories = maximumCalories - netCalories;

    // Calculate calorie percentage based on net calories vs maximum
    double caloriesPercent = (netCalories / maximumCalories).clamp(0.0, 1.0);

    // Determine if user has exceeded their calorie limit
    bool exceededLimit = actualRemainingCalories < 0;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Enhanced Calories Card with Clear Max/Consumed/Exceeded Indicators
          Bounceable(
            onTap: () {},
            child: PhysicalModel(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14),
              elevation: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  // margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: MealAIColors.whiteText,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 4.w, right: 4.w, top: 2.h, bottom: 2.h),
                    child: Column(
                      children: [
                        // Header with Title and Status Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Daily Nutrition",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: exceededLimit
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    exceededLimit
                                        ? Icons.warning_rounded
                                        : Icons.check_circle_outline,
                                    color: exceededLimit
                                        ? Colors.red
                                        : Colors.green,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    exceededLimit
                                        ? "Limit Exceeded"
                                        : "On Track",
                                    style: TextStyle(
                                      color: exceededLimit
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 2.h),

                        // Main Calorie Information
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left Column: Calorie Stats
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Calorie Counter Card
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: exceededLimit
                                        ? Colors.red.withOpacity(0.05)
                                        : Colors.grey.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Calories",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "$netCalories",
                                              style: TextStyle(
                                                color: exceededLimit
                                                    ? Colors.red
                                                    : Colors.black,
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: " / $maximumCalories",
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      exceededLimit
                                          ? Text(
                                              "${actualRemainingCalories.abs()} calories over limit",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          : Text(
                                              "$remainingCalories calories remaining",
                                              style: TextStyle(
                                                color: Colors.green.shade700,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 1.h),

                                // Calories In/Out Row
                                Row(
                                  children: [
                                    _buildCalorieInfoBox(
                                      "Consumed",
                                      consumedCalories,
                                      Icons.add_circle_outline,
                                      Colors.blue.shade700,
                                    ),
                                    SizedBox(width: 8),
                                    _buildCalorieInfoBox(
                                      "Burned",
                                      burnedCalories,
                                      Icons.local_fire_department,
                                      Colors.orange.shade700,
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Right Column: Progress Circle
                            CircularPercentIndicator(
                              radius: 60,
                              lineWidth: 12.0,
                              animation: true,
                              animationDuration: 1000,
                              percent: caloriesPercent,
                              backgroundColor: MealAIColors.gaugeColor,
                              progressColor: _getProgressColor(
                                  caloriesPercent, exceededLimit),
                              circularStrokeCap: CircularStrokeCap.round,
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${(caloriesPercent * 100).toInt()}%",
                                    style: TextStyle(
                                      color: exceededLimit
                                          ? Colors.red
                                          : Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "consumed",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          // Nutrients Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 2.w,
            children: [
              // Proteins
              _buildNutrientBox(
                "Proteins",
                consumedProtein,
                maximumProtein,
                MealAIColors.proteinColor,
                Icons.fitness_center,
              ),

              // Carbs
              _buildNutrientBox(
                "Carbs",
                consumedCarb,
                maximumCarb,
                MealAIColors.carbsColor,
                Icons.grain,
              ),

              // Fats
              _buildNutrientBox(
                "Fats",
                consumedFat,
                maximumFat,
                MealAIColors.fatColor,
                Icons.opacity,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for calorie in/out information
  Widget _buildCalorieInfoBox(
      String label, int value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
              Text(
                "$value",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to determine progress color based on percentage
  Color _getProgressColor(double percent, bool exceeded) {
    if (exceeded) return Colors.red;
    if (percent > 0.9) return Colors.orange;
    if (percent > 0.75) return Colors.amber;
    return MealAIColors.black;
  }

  Widget _buildNutrientBox(
      String label, int value, int max, Color color, IconData icon) {
    double percent = (value / max).clamp(0.0, 1.0);
    bool exceededLimit = value > max;

    return Expanded(
      child: Bounceable(
        onTap: () => {},
        child: PhysicalModel(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
          elevation: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              // margin: EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: MealAIColors.whiteText,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon,
                          color: exceededLimit ? Colors.red : color, size: 16),
                      SizedBox(width: 4),
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.8.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "$value",
                          style: TextStyle(
                            color: exceededLimit ? Colors.red : Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "/$max g",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  LinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        exceededLimit ? Colors.red : color),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
