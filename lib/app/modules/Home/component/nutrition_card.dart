import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:turfit/app/constants/enums.dart';
import 'package:turfit/app/models/AI/nutrition_record.dart';

class NutritionCard extends StatelessWidget {
  final NutritionRecord nutritionRecord;
  const NutritionCard({super.key, required this.nutritionRecord});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: nutritionRecord.processingStatus == ProcessingStatus.PROCESSING
          ? Row(
              children: [
                // nutritionRecord.processingStatus == ProcessingStatus.PROCESSING
                //     ? Image.file(
                //         File(nutritionRecord.nutritionInputQuery!.imageFilePath!))
                // : CachedNetworkImage(
                //     imageUrl: nutritionRecord.nutritionInputQuery!.imageUrl!,
                //     placeholder: (context, url) => CircularProgressIndicator(),
                //     width: 20.w,
                //     height: 10.h,
                //   ),

                Image.file(
                  File(nutritionRecord.nutritionInputQuery!.imageFilePath!),
                  width: 20.w,
                  height: 10.h,
                ),

                Text("Processing..."),
              ],
            )
          : Row(
              children: [],
            ),
    );
  }
}
