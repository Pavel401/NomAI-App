// import 'package:flutter/material.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:sizer/sizer.dart';
// import 'package:turfit/app/constants/colors.dart';

// class NutritionTrackerCard extends StatelessWidget {
//   const NutritionTrackerCard({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: MealAIColors.whiteText,
//       margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Left section - Circular progress with calories
//                 Expanded(
//                   flex: 1,
//                   child: CircularPercentIndicator(
//                     radius: 80,
//                     lineWidth: 10.0,
//                     percent: 0.0,
//                     backgroundColor: Colors.grey.shade200,
//                     progressColor: Colors.blue,
//                     center: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           "Consumed:",
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const Text(
//                           "0",
//                           style: TextStyle(
//                             color: Color(0xFF2D3142),
//                             fontSize: 42,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           "/2573 kcal",
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Right section - Nutrients breakdown
//                 Expanded(
//                   flex: 1,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       // Score indicator
//                       Container(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade200,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               "-- ",
//                               style: TextStyle(
//                                 color: Colors.grey,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               "No score",
//                               style: TextStyle(
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 20),

//                       // Nutrient bars
//                       _buildNutrientBar("Fat", "0", "85g"),
//                       SizedBox(height: 16),
//                       _buildNutrientBar("Protein", "0", "128g"),
//                       SizedBox(height: 16),
//                       _buildNutrientBar("Carb", "0", "321g"),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),

//             // Bottom action buttons
//             Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(vertical: 12),
//                     decoration: BoxDecoration(
//                       color: Color(0xFFFCECE7),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.local_fire_department, color: Colors.red),
//                         SizedBox(width: 8),
//                         Text(
//                           "BURNED: 0",
//                           style: TextStyle(
//                             color: Colors.brown,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(vertical: 12),
//                     decoration: BoxDecoration(
//                       color: Color(0xFFF0F9E8),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.restaurant, color: Colors.green),
//                         SizedBox(width: 8),
//                         Text(
//                           "CONSUMED: 0",
//                           style: TextStyle(
//                             color: Colors.green,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNutrientBar(String label, String value, String total) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 16,
//               ),
//             ),
//             RichText(
//               text: TextSpan(
//                 children: [
//                   TextSpan(
//                     text: value,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "/$total",
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 6),
//         Container(
//           height: 8,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sizer/sizer.dart';
import 'package:turfit/app/constants/colors.dart';

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
    int remainingCalories = maximumCalories - consumedCalories;
    double caloriesPercent =
        (consumedCalories / maximumCalories).clamp(0.0, 1.0);

    return Column(
      children: [
        // Calories Card
        Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: MealAIColors.whiteText,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding:
                EdgeInsets.only(left: 4.w, right: 4.w, top: 2.h, bottom: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      remainingCalories.toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Calories Remaining",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: MealAIColors.black,
                          size: 16,
                        ),
                        SizedBox(width: 0.5.w),
                        Text(
                          "${consumedCalories} consumed",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                        SizedBox(width: 0.5.w),
                        Text(
                          "${burnedCalories} burned",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: 2.w),
                CircularPercentIndicator(
                  radius: 60,
                  lineWidth: 10.0,
                  percent: caloriesPercent,
                  backgroundColor: MealAIColors.gaugeColor,
                  progressColor:
                      caloriesPercent > 0.9 ? Colors.red : MealAIColors.black,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: MealAIColors.greyLight,
                        child: Icon(
                          Icons.local_fire_department,
                          color: MealAIColors.black,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Nutrients Row
        Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Proteins
              _buildNutrientBox(
                "Proteins",
                consumedProtein,
                maximumProtein,
                Colors.blue.shade700,
                Icons.fitness_center,
              ),

              // Carbs
              _buildNutrientBox(
                "Carbs",
                consumedCarb,
                maximumCarb,
                Colors.orange.shade700,
                Icons.grain,
              ),

              // Fats
              _buildNutrientBox(
                "Fats",
                consumedFat,
                maximumFat,
                Colors.green.shade700,
                Icons.opacity,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientBox(
      String label, int value, int max, Color color, IconData icon) {
    double percent = (value / max).clamp(0.0, 1.0);

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: MealAIColors.whiteText,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 16),
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
            Text(
              "$value/$max g",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 0.8.h),
            LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientProgressBar(String label, String value, String total,
      double percent, Color color, BuildContext context) {
    percent = percent.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: "/$total g",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Container(
              height: 10,
              width: MediaQuery.of(context).size.width * 0.8 * percent,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
