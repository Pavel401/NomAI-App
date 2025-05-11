// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:timeline_date_picker_plus/timeline_date_picker_plus.dart';
import 'package:turfit/app/components/nutritionTrackerCard.dart'
    show NutritionTrackerCard;
import 'package:turfit/app/constants/colors.dart';
import 'package:turfit/app/models/AI/nutrition_record.dart';
import 'package:turfit/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:turfit/app/modules/Home/component/nutrition_card.dart';
import 'package:turfit/app/modules/Home/views/nutrition_view.dart';
import 'package:turfit/app/modules/Scanner/controller/scanner_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScannerController _scannerController;
  late String _userId;

  DateTime _selectedDate = DateTime.now();

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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Nutrition Scanner',
          style: TextStyle(color: MealAIColors.whiteText),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF817C88),
            child: IconButton(
              icon: const Icon(Icons.local_fire_department_outlined),
              color: MealAIColors.whiteText,
              onPressed: () {},
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF817C88),
              child: IconButton(
                icon: const Icon(Icons.settings_outlined),
                color: MealAIColors.whiteText,
                onPressed: () {},
              ),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MealAIColors.blueGrey,
              MealAIColors.blueGrey.withOpacity(0.9),
              MealAIColors.blueGrey.withOpacity(0.8),
              MealAIColors.blueGrey.withOpacity(0.7),
              MealAIColors.blueGrey.withOpacity(0.6),
              MealAIColors.blueGrey.withOpacity(0.5),
              MealAIColors.blueGrey.withOpacity(0.4),
              MealAIColors.blueGrey.withOpacity(0.3),
              MealAIColors.blueGrey.withOpacity(0.2),
              MealAIColors.blueGrey.withOpacity(0.1),
              MealAIColors.whiteText,
            ],
            stops: const [
              0.0,
              0.1,
              0.2,
              0.3,
              0.4,
              0.5,
              0.6,
              0.7,
              0.8,
              0.9,
              1.0,
            ],
          ),
        ),
        child: ListView(
          children: [
            Center(
              child: DateScroller(
                initialDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 6)),
                selectedDate: _selectedDate,
                showMonthName: false,
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                  _scannerController.getRecordByDate(_userId, date);
                },
                showScheduleDots: true,
                scheduleCounts: {},
                selectedShape: DateSelectedShape.circle,
                selectedDateBackgroundColor: MealAIColors
                    .selectedTile, // A vibrant contrast color from your palette
                dayNameColor: Colors.white70,
                dayNameSundayColor: MealAIColors.red,
                dayNumberColor: Colors.white,
                dayNumberSundayColor: MealAIColors.red,
                dayNumberSelectedColor: MealAIColors.whiteText,
                activeMonthTextColor: Colors.white,
                dayNameTextStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                dayNumberTextStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                monthTextStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),

            /// Nutrition Tracker Card
            NutritionTrackerCard(
                maximumCalories: 2521,
                consumedCalories: 670,
                burnedCalories: 200,
                maximumFat: 85,
                consumedFat: 12,
                maximumProtein: 400,
                consumedProtein: 123,
                maximumCarb: 300,
                consumedCarb: 200),

            SizedBox(
              height: 2.h,
            ),

            ///Meals List
            Padding(
              padding: EdgeInsets.only(left: 4.w, right: 4.w),
              child: Row(
                children: [
                  Text("Recently Eaten",
                      style: TextStyle(
                        color: MealAIColors.blackText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
            GetBuilder<ScannerController>(
              builder: (controller) {
                if (controller.isLoading && controller.dailyRecords.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: MealAIColors.selectedTile,
                    ),
                  );
                }

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

                return ListView.builder(
                  itemCount: controller.dailyRecords.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                  itemBuilder: (context, index) {
                    NutritionRecord record = controller.dailyRecords[index];
                    return NutritionCard(
                      nutritionRecord: record,
                      onTap: () {
                        Get.to(() => NutritionView(nutritionRecord: record));
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
