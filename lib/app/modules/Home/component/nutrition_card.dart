import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
                Image.file(
                  File(nutritionRecord.nutritionInputQuery!.imageFilePath!),
                  width: 20.w,
                  height: 10.h,
                ),
                SizedBox(width: 8),
                Text("Processing..."),
              ],
            )
          : Row(
              children: [
                CachedNetworkImage(
                  imageUrl: nutritionRecord.nutritionInputQuery!.imageUrl!,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  width: 20.w,
                  height: 10.h,
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Record Time: ${nutritionRecord.recordTime}",
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    Text(
                      "Status: Completed",
                      style: TextStyle(fontSize: 10.sp, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
