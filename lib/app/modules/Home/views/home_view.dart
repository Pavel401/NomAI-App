import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:turfit/app/constants/colors.dart';
import 'package:turfit/app/models/AI/nutrition_record.dart';
import 'package:turfit/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:turfit/app/modules/Home/component/nutrition_card.dart';
import 'package:turfit/app/modules/Scanner/controller/scanner_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScannerController _scannerController;
  late String _userId;

  @override
  void initState() {
    super.initState();
    // Initialize scanner controller
    _scannerController = Get.put(ScannerController());

    // Get user ID from authentication bloc
    _userId = context.read<AuthenticationBloc>().state.user!.uid;

    // Fetch initial records
    _fetchRecords();
  }

  void _fetchRecords() {
    _scannerController.getRecordByDate(
        _userId, _scannerController.selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealAIColors.lightGreyTile,
      appBar: AppBar(
        backgroundColor: MealAIColors.selectedTile,
        title: Text(
          'Nutrition Scanner',
          style: TextStyle(color: MealAIColors.whiteText),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Date Selection Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  'Select Date',
                  style: TextStyle(
                    color: MealAIColors.blackText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  Icons.calendar_today,
                  color: MealAIColors.selectedTile,
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _scannerController.selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: MealAIColors.selectedTile,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (picked != null &&
                      picked != _scannerController.selectedDate) {
                    _scannerController.selectedDate = picked;
                    _scannerController.getRecordByDate(_userId, picked);
                  }
                },
              ),
            ),
          ),

          // Nutrition Records List
          Expanded(
            child: GetBuilder<ScannerController>(
              builder: (controller) {
                // Check loading state
                if (controller.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: MealAIColors.selectedTile,
                    ),
                  );
                }

                // Check if records are empty
                if (controller.dailyRecords.isEmpty) {
                  return Center(
                    child: Text(
                      'No nutrition records found',
                      style: TextStyle(
                        color: MealAIColors.blackText,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                // Build list of records
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.dailyRecords.length,
                  itemBuilder: (context, index) {
                    NutritionRecord record = controller.dailyRecords[index];
                    return NutritionCard(nutritionRecord: record!);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
