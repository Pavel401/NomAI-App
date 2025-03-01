import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:turfit/app/constants/colors.dart';

class PrimaryTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const PrimaryTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(bottom: 2.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? MealAIColors.selectedTile
              : MealAIColors.lightGreyTile,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? MealAIColors.whiteText
                      : MealAIColors.blackText),
            ),
          ],
        ),
      ),
    );
  }
}
