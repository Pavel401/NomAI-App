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
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with Image
          _buildSliverAppBar(context),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Food Header Card
                _buildFoodHeaderCard(context, response),

                // Nutrition Summary Card
                _buildNutritionSummaryCard(context, response),

                // Health Insights Card
                if (response.overallHealthComments != null &&
                    response.overallHealthComments!.isNotEmpty)
                  _buildHealthInsightsCard(context, response),

                // Ingredients Card
                if (response.ingredients != null &&
                    response.ingredients!.isNotEmpty)
                  _buildIngredientsCard(context, response),

                // Primary Concerns Card
                if (response.primaryConcerns != null &&
                    response.primaryConcerns!.isNotEmpty)
                  _buildPrimaryConcernsCard(context, response),

                // Alternatives Card
                if (response.suggestAlternatives != null &&
                    response.suggestAlternatives!.isNotEmpty)
                  _buildAlternativesCard(context, response),

                SizedBox(height: 3.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 35.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Bounceable(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black87, size: 20),
        ),
      ),
      actions: [
        Bounceable(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.ios_share, color: Colors.black87, size: 20),
          ),
        ),
        Bounceable(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: nutritionRecord.nutritionInputQuery?.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: nutritionRecord.nutritionInputQuery!.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.black54),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No Image Available',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No Image Available',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildFoodHeaderCard(
      BuildContext context, NutritionResponse response) {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            response.foodName ?? 'Unknown Food',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (response.overallHealthScore != null) ...[
            SizedBox(height: 2.h),
            EnhancedHealthScoreWidget(nutritionRecord: nutritionRecord),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionSummaryCard(
      BuildContext context, NutritionResponse response) {
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
        totalFiber += ingredient.fiber ?? 0;
      }
    }

    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.analytics_outlined,
                    color: Colors.blue.shade600, size: 20),
              ),
              SizedBox(width: 2.w),
              Text(
                'Nutrition Facts',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Calories Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade300],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calories',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$totalCalories kcal',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          // Macronutrients
          Row(
            children: [
              Expanded(
                child: _buildEnhancedNutrientBox(
                  context,
                  'Carbs',
                  '$totalCarbs',
                  'g',
                  MealAIColors.carbsColor ?? Colors.blue.shade300,
                  Icons.grain,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildEnhancedNutrientBox(
                  context,
                  'Protein',
                  '$totalProtein',
                  'g',
                  MealAIColors.proteinColor ?? Colors.red.shade300,
                  Icons.fitness_center,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildEnhancedNutrientBox(
                  context,
                  'Fat',
                  '$totalFat',
                  'g',
                  MealAIColors.fatColor ?? Colors.yellow.shade300,
                  Icons.water_drop,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedNutrientBox(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color backgroundColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: backgroundColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
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
                  color: backgroundColor,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInsightsCard(
      BuildContext context, NutritionResponse response) {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.psychology_outlined,
                    color: Colors.green.shade600, size: 20),
              ),
              SizedBox(width: 2.w),
              Text(
                'Health Insights',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              response.overallHealthComments ?? '',
              style: context.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsCard(
      BuildContext context, NutritionResponse response) {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.restaurant_menu,
                    color: Colors.purple.shade600, size: 20),
              ),
              SizedBox(width: 2.w),
              Text(
                'Ingredients',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: response.ingredients?.length ?? 0,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ingredient = response.ingredients![index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            ingredient.name ?? 'Unknown',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (ingredient.healthComments != null &&
                        ingredient.healthComments!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          ingredient.healthComments!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryConcernsCard(
      BuildContext context, NutritionResponse response) {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.warning_amber_outlined,
                    color: Colors.orange.shade600, size: 20),
              ),
              SizedBox(width: 2.w),
              Text(
                'Primary Concerns',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: response.primaryConcerns?.length ?? 0,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final concern = response.primaryConcerns![index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.orange.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            concern.issue ?? 'Unknown Concern',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      concern.explanation ?? 'No explanation available',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    if (concern.recommendations != null &&
                        concern.recommendations!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Recommendations:',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (Recommendation suggestion
                          in concern.recommendations!)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade600,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${suggestion.food} - ${suggestion.reasoning} (${suggestion.quantity})',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativesCard(
      BuildContext context, NutritionResponse response) {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lightbulb_outline,
                    color: Colors.green.shade600, size: 20),
              ),
              SizedBox(width: 2.w),
              Text(
                'Healthier Alternatives',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: response.suggestAlternatives?.length ?? 0,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alternative = response.suggestAlternatives![index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade50,
                      Colors.green.shade100 ?? Colors.green.shade50
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up,
                            color: Colors.green.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alternative.name ?? 'Unknown',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                        if (alternative.healthScore != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${alternative.healthScore}/10',
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
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class EnhancedHealthScoreWidget extends StatelessWidget {
  final NutritionRecord nutritionRecord;

  const EnhancedHealthScoreWidget({
    super.key,
    required this.nutritionRecord,
  });

  @override
  Widget build(BuildContext context) {
    double scorePercent = (nutritionRecord
            .nutritionOutput!.response!.overallHealthScore!
            .clamp(0, 10)) /
        10;

    int healthScore = nutritionRecord
        .nutritionOutput!.response!.overallHealthScore!
        .clamp(0, 10)
        .toInt();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getProgressColor(scorePercent).withOpacity(0.1),
            _getProgressColor(scorePercent).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: _getProgressColor(scorePercent).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Time Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Meal Time",
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateUtility.getTimeFromDateTime(
                    nutritionRecord.recordTime?.toLocal() ?? DateTime.now(),
                  ),
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Health Score
          Column(
            children: [
              CircularPercentIndicator(
                radius: 8.w,
                lineWidth: 6.0,
                animation: true,
                animationDuration: 1200,
                percent: scorePercent,
                backgroundColor: Colors.grey.shade200,
                progressColor: _getProgressColor(scorePercent),
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  '$healthScore',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(scorePercent),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getHealthRating(healthScore),
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(scorePercent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percent) {
    if (percent >= 0.8) return Colors.green.shade600;
    if (percent >= 0.6) return Colors.orange.shade600;
    if (percent >= 0.4) return Colors.orange.shade700;
    return Colors.red.shade600;
  }

  String _getHealthRating(int score) {
    if (score >= 8) return 'Excellent';
    if (score >= 6) return 'Good';
    if (score >= 4) return 'Fair';
    return 'Poor';
  }
}
