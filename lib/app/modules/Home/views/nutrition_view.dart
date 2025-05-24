import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sizer/sizer.dart';

// Assuming these are defined elsewhere in your codebase
import 'package:turfit/app/constants/colors.dart';
import 'package:turfit/app/models/AI/nutrition_output.dart';
import 'package:turfit/app/models/AI/nutrition_record.dart';
import 'package:turfit/app/utility/date_utility.dart';

class NutritionView extends StatelessWidget {
  final NutritionRecord nutritionRecord;

  const NutritionView({super.key, required this.nutritionRecord});

  @override
  Widget build(BuildContext context) {
    NutritionResponse response = nutritionRecord.nutritionOutput!.response!;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Image
              _buildFoodImage(),

              // Food Details
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food Name and Health Score
                    _buildFoodHeader(context, response),

                    const SizedBox(height: 24),

                    // Nutrition Summary
                    _buildNutritionSummary(context, response),

                    const SizedBox(height: 24),

                    // Health Comments
                    if (response.overallHealthComments != null &&
                        response.overallHealthComments!.isNotEmpty)
                      _buildHealthComments(context, response),

                    const SizedBox(height: 24),

                    // Ingredient List
                    if (response.ingredients != null &&
                        response.ingredients!.isNotEmpty)
                      _buildIngredientsList(context, response),

                    const SizedBox(height: 24),

                    // Alternative Suggestions
                    if (response.suggestAlternatives != null &&
                        response.suggestAlternatives!.isNotEmpty)
                      _buildAlternativesList(context, response),

                    if (response.primaryConcerns != null &&
                        response.primaryConcerns!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Primary Concerns',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (var concern in response.primaryConcerns!)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              concern.issue ?? 'Unknown Concern',
                              style: context.textTheme.bodyMedium,
                            ),
                            Text(
                              concern.explanation ?? 'Unknown Concern',
                              style: context.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            for (Recommendation suggestion
                                in concern.recommendations ?? [])
                              Text(
                                '- ${suggestion.food} -- ${suggestion.reasoning} -- ${suggestion.quantity}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            const SizedBox(height: 12),
                          ],
                        )
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Bounceable(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: MealAIColors.greyLight,
          ),
          child:
              Icon(Icons.chevron_left, color: MealAIColors.blueGrey, size: 30),
        ),
      ),
      title: const Text('Nutrition'),
      centerTitle: true,
      actions: [
        Bounceable(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: MealAIColors.greyLight,
            ),
            child: Icon(Icons.ios_share_outlined, color: MealAIColors.blueGrey),
          ),
        ),
        Bounceable(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: MealAIColors.greyLight,
            ),
            child: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodImage() {
    return Center(
      child: Container(
        width: double.infinity,
        height: 30.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: nutritionRecord.nutritionInputQuery?.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: nutritionRecord.nutritionInputQuery!.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.black),
                        SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  'No Image Available',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
      ),
    );
  }

  Widget _buildFoodHeader(BuildContext context, NutritionResponse response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                response.foodName ?? 'Unknown Food',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        if (response.overallHealthScore != null) ...[
          SizedBox(height: 2.h),
          HealthScoreWidget(
            nutritionRecord: nutritionRecord,
          ),
        ],
      ],
    );
  }

  Widget _buildNutritionSummary(
      BuildContext context, NutritionResponse response) {
    // Calculate total nutritional values from all ingredients
    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;
    int totalFiber = 0;

    if (response.ingredients != null) {
      for (var ingredient in response.ingredients!) {
        totalCalories += ingredient.calories ?? 0;
        totalProtein += ingredient.protein ?? 0;
        totalCarbs += ingredient.carbs ?? 0;
        totalFat += ingredient.fat ?? 0;
        totalFiber += ingredient.fiber ?? 0; // Changed from fibre to fiber
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrition Facts',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Expanded(
            //   child: _buildNutrientBox(
            //     context,
            //     'Calories',
            //     '$totalCalories',
            //     'kcal',
            //     Colors.orange.shade200,
            //   ),
            // ),
            Expanded(
              child: _buildNutrientBox(
                context,
                'Carbs',
                '$totalCarbs',
                'g',
                MealAIColors.carbsColor,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildNutrientBox(
                context,
                'Protein',
                '$totalProtein',
                'g',
                MealAIColors.proteinColor,
              ),
            ),
            SizedBox(width: 2.w),

            Expanded(
              child: _buildNutrientBox(
                context,
                'Fat',
                '$totalFat',
                'g',
                MealAIColors.fatColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutrientBox(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthComments(
      BuildContext context, NutritionResponse response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Insights',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            response.overallHealthComments ?? '',
            style: context.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsList(
      BuildContext context, NutritionResponse response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: response.ingredients?.length ?? 0,
          itemBuilder: (context, index) {
            final ingredient = response.ingredients![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            ingredient.name ?? 'Unknown',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Note: Removed quantity and portion fields as they're not in the model
                      ],
                    ),
                    // const SizedBox(height: 8),
                    // Row(
                    //   children: [
                    //     _buildIngredientNutrient(
                    //         'Cal', '${ingredient.calories ?? 0}'),
                    //     _buildIngredientNutrient(
                    //         'P', '${ingredient.protein ?? 0}g'),
                    //     _buildIngredientNutrient(
                    //         'C', '${ingredient.carbs ?? 0}g'),
                    //     _buildIngredientNutrient(
                    //         'F', '${ingredient.fat ?? 0}g'),
                    //     _buildIngredientNutrient('Fiber',
                    //         '${ingredient.fiber ?? 0}g'), // Changed from fibre to fiber
                    //   ],
                    // ),
                    if (ingredient.healthComments != null &&
                        ingredient.healthComments!.isNotEmpty) ...[
                      SizedBox(height: 1.h),
                      Text(
                        ingredient.healthComments!,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildIngredientNutrient(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativesList(
      BuildContext context, NutritionResponse response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Healthier Alternatives',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: response.suggestAlternatives?.length ?? 0,
          itemBuilder: (context, index) {
            final alternative = response.suggestAlternatives![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            alternative.name ?? 'Unknown',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (alternative.healthScore != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Score: ${alternative.healthScore}',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (alternative.healthComments != null &&
                        alternative.healthComments!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        alternative.healthComments!,
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class HealthScoreWidget extends StatelessWidget {
  // final int healthScore; // Should be between 0 and 10
  final NutritionRecord nutritionRecord;
  const HealthScoreWidget({
    super.key,
    required this.nutritionRecord,
  });

  @override
  Widget build(BuildContext context) {
    // Clamp score between 0.0 and 1.0
    double scorePercent = (nutritionRecord
            .nutritionOutput!.response!.overallHealthScore!
            .clamp(0, 10)) /
        10;

    int healthScore = nutritionRecord
        .nutritionOutput!.response!.overallHealthScore!
        .clamp(0, 10)
        .toInt();

    return Row(
      children: [
        Text("Meal Time : ",
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )),
        Text(
          DateUtility.getTimeFromDateTime(
            nutritionRecord.recordTime?.toLocal() ?? DateTime.now(),
          ),
          style: context.textTheme.bodyMedium?.copyWith(
            color: MealAIColors.grey,
          ),
        ),
        Expanded(child: Container()),
        Text(
          "Health Score: ",
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        CircularPercentIndicator(
          radius: 5.w,
          lineWidth: 2.0,
          animation: true,
          animationDuration: 1000,
          percent: scorePercent,
          backgroundColor: Colors.grey.shade200,
          progressColor: _getProgressColor(scorePercent),
          circularStrokeCap: CircularStrokeCap.round,
          center: Text(
            '$healthScore',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getProgressColor(scorePercent),
            ),
          ),
        ),
      ],
    );

    // return Column(
    //   children: [
    //     CircularPercentIndicator(
    //       radius: 50,
    //       lineWidth: 10.0,
    //       animation: true,
    //       animationDuration: 1000,
    //       percent: scorePercent,
    //       backgroundColor: Colors.grey.shade200,
    //       progressColor: _getProgressColor(scorePercent),
    //       circularStrokeCap: CircularStrokeCap.round,
    //       center: Text(
    //         '$healthScore',
    //         style: context.textTheme.headlineMedium?.copyWith(
    //               fontWeight: FontWeight.bold,
    //               color: _getProgressColor(scorePercent),
    //             ),
    //       ),
    //     ),
    //     const SizedBox(height: 8),
    //     Text(
    //       'Health Score',
    //       style: context.textTheme.bodyMedium?.copyWith(
    //             color: Colors.grey.shade700,
    //           ),
    //     ),
    //     const SizedBox(height: 4),
    //     Text(
    //       _getHealthRating(healthScore),
    //       style: context.textTheme.bodyMedium?.copyWith(
    //             fontWeight: FontWeight.bold,
    //             color: _getProgressColor(scorePercent),
    //           ),
    //     ),
    //   ],
    // );
  }

  Color _getProgressColor(double percent) {
    if (percent >= 0.8) return Colors.green;
    if (percent >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _getHealthRating(int score) {
    if (score >= 8) return 'Excellent';
    if (score >= 6) return 'Good';
    if (score >= 4) return 'Fair';
    return 'Poor';
  }
}
