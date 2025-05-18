import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:turfit/app/constants/colors.dart';
import 'package:turfit/app/constants/enums.dart';
import 'package:turfit/app/models/AI/nutrition_output.dart';
import 'package:turfit/app/models/AI/nutrition_record.dart';
import 'package:turfit/app/utility/date_utility.dart';

class NutritionCard extends StatelessWidget {
  final NutritionRecord nutritionRecord;
  final void Function() onTap;

  const NutritionCard({
    Key? key,
    required this.nutritionRecord,
    required this.onTap,
  }) : super(key: key);

  // Calculate total nutritional values from the entire nutritionData list
  Map<String, int> get _totalNutrition {
    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    if (nutritionRecord.nutritionOutput != null &&
        nutritionRecord.processingStatus != ProcessingStatus.PROCESSING) {
      final nutritionData =
          nutritionRecord.nutritionOutput!.response?.ingredients;
      for (Ingredient item in nutritionData ?? []) {
        totalCalories += item.calories!;
        totalProtein += item.protein!;
        totalCarbs += item.carbs!;
        totalFat += item.fat!;
      }
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }

  @override
  Widget build(BuildContext context) {
    final totals = _totalNutrition;
    final isProcessing =
        nutritionRecord.processingStatus == ProcessingStatus.PROCESSING;

    return Bounceable(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.08),
          //     blurRadius: 10,
          //     offset: Offset(0, 4),
          //   ),
          // ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: isProcessing
              ? _buildProcessingCard(context)
              : _buildCompletedCard(context, totals),
        ),
      ),
    );
  }

  Widget _buildProcessingCard(BuildContext context) {
    return Container(
      height: 12.h,
      child: Row(
        children: [
          _buildFoodImage(context, 25.w, 12.h),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              MealAIColors.darkPrimary),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Analyzing your food...",
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We're calculating the nutritional value",
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // _buildChevron(context),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(BuildContext context, Map<String, int> totals) {
    // Fetching food name from the first item in the list
    final foodName = nutritionRecord.nutritionOutput?.response!.foodName != null
        ? nutritionRecord.nutritionOutput?.response!.foodName
        : "Unknown Food";

    return Container(
      height: 16.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFoodImage(context, 25.w, 16.h),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              foodName ?? "Unknown Food",
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: MealAIColors.lightGreyTile,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              DateUtility.getTimeFromDateTime(
                                nutritionRecord.recordTime!.toLocal(),
                              ),
                              style: context.textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: MealAIColors.darkPrimary,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "${totals['calories']} kcal",
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: MealAIColors.darkPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Nutrition badges row
                  _buildNutritionBadgesRow(context, totals),
                ],
              ),
            ),
          ),
          // _buildChevron(context),
        ],
      ),
    );
  }

  Widget _buildFoodImage(BuildContext context, double width, double height) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      child: Container(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image or placeholder
            if (nutritionRecord.nutritionInputQuery?.imageFilePath != null)
              Image.file(
                File(nutritionRecord.nutritionInputQuery!.imageFilePath!),
                width: 25.w,
                height: 12.h,
                fit: BoxFit.cover,
              )
            else if (nutritionRecord.nutritionInputQuery?.imageUrl != null)
              CachedNetworkImage(
                imageUrl: nutritionRecord.nutritionInputQuery!.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildImagePlaceholder(),
                errorWidget: (context, url, error) => _buildImageError(),
              )
            else
              _buildImagePlaceholder(),

            // Optional: Add a subtle gradient overlay for better text contrast
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.restaurant,
          color: Colors.grey[400],
          size: 32,
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.red[300],
          size: 32,
        ),
      ),
    );
  }

  Widget _buildNutritionBadgesRow(
      BuildContext context, Map<String, int> totals) {
    return Row(
      children: [
        Expanded(
            child: _buildMacroNutrientBadge(
          context,
          "PROTEIN",
          "${totals['protein']}g",
          MealAIColors.proteinColor,
          Icons.fitness_center_rounded,
        )),
        SizedBox(width: 2.w),
        Expanded(
            child: _buildMacroNutrientBadge(
          context,
          "CARBS",
          "${totals['carbs']}g",
          MealAIColors.carbsColor,
          Icons.grain_rounded,
        )),
        SizedBox(width: 2.w),
        Expanded(
            child: _buildMacroNutrientBadge(
          context,
          "FAT",
          "${totals['fat']}g",
          MealAIColors.fatColor,
          Icons.opacity_rounded,
        )),
      ],
    );
  }

  Widget _buildMacroNutrientBadge(BuildContext context, String label,
      String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: color.withOpacity(0.8),
                  fontSize: 6.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChevron(BuildContext context) {
    return Container(
      width: 8.w,
      decoration: BoxDecoration(
        color: MealAIColors.darkPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.chevron_right_rounded,
          color: MealAIColors.darkPrimary,
          size: 24,
        ),
      ),
    );
  }
}
