import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:turfit/app/constants/colors.dart';
import 'package:turfit/app/constants/enums.dart';
import 'package:turfit/app/models/AI/nutrition_output.dart';
import 'package:turfit/app/models/AI/nutrition_record.dart';

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

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: nutritionRecord.processingStatus == ProcessingStatus.PROCESSING
            ? _buildProcessingCard(context)
            : _buildCompletedCard(context, totals),
      ),
    );
  }

  Widget _buildProcessingCard(BuildContext context) {
    return Container(
      height: 12.h,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: nutritionRecord.nutritionInputQuery?.imageFilePath != null
                ? Image.file(
                    File(nutritionRecord.nutritionInputQuery!.imageFilePath!),
                    width: 25.w,
                    height: 12.h,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 25.w,
                    height: 12.h,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, color: Colors.grey[600]),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Analyzing your food...",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(MealAIColors.darkPrimary),
                  ),
                ],
              ),
            ),
          ),
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
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: nutritionRecord.nutritionInputQuery?.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: nutritionRecord.nutritionInputQuery!.imageUrl,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                    width: 25.w,
                    height: 16.h,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 25.w,
                    height: 16.h,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, color: Colors.grey[600]),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    foodName!,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  // Display total nutrition info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNutritionRow(
                        context,
                        Icons.local_fire_department,
                        "${totals['calories']} kcal",
                        MealAIColors.darkPrimary,
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          _buildNutritionBadge(
                            context,
                            "CARBS",
                            "${totals['carbs']}g",
                            Colors.amber[700]!,
                          ),
                          SizedBox(width: 4),
                          _buildNutritionBadge(
                            context,
                            "PROTEIN",
                            "${totals['protein']}g",
                            Colors.green[700]!,
                          ),
                          SizedBox(width: 4),
                          _buildNutritionBadge(
                            context,
                            "FAT",
                            "${totals['fat']}g",
                            Colors.red[700]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 16.h,
            width: 8.w,
            decoration: BoxDecoration(
              color: MealAIColors.darkPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.arrow_forward_ios,
                color: MealAIColors.darkPrimary,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(
      BuildContext context, IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 4),
        Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionBadge(
      BuildContext context, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: value,
              style: context.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: " $label",
              style: context.textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.8),
                fontSize: 6.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
