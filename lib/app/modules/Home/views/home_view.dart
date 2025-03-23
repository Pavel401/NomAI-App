import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turfit/app/models/AI/nutrition_record.dart';
import 'package:turfit/app/modules/Scanner/controller/scanner_controller.dart';

class HomePage extends StatelessWidget {
  final ScannerController scannerController = Get.put(ScannerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition Scanner'),
      ),
      body: Obx(() {
        if (scannerController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: scannerController.dailyRecords.length,
          itemBuilder: (context, index) {
            NutritionRecord record = scannerController.dailyRecords[index];
            return ListTile(
              leading: Image.network(record.nutritionInputQuery.imageUrl!),
              title: Text('Nutrition Record ${index + 1}'),
              subtitle: Text('Processed at: ${record.recordTime}'),
            );
          },
        );
      }),
    );
  }
}
