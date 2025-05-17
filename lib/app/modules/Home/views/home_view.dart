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
import 'package:turfit/app/models/Auth/user.dart';
import 'package:turfit/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:turfit/app/modules/Demo/views/bounce.dart';
import 'package:turfit/app/modules/Home/component/nutrition_card.dart';
import 'package:turfit/app/modules/Home/views/nutrition_view.dart';
import 'package:turfit/app/modules/Scanner/controller/scanner_controller.dart';
import 'package:turfit/app/repo/firebase_user_repo.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScannerController _scannerController;
  late String _userId;

  DateTime _selectedDate = DateTime.now();

  late AuthenticationBloc authenticationBloc;
  final FirebaseUserRepo _userRepository = FirebaseUserRepo();

  UserModel? userModel;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize scanner controller
    _scannerController = Get.put(ScannerController());
    authenticationBloc = context.read<AuthenticationBloc>();
    // Get user ID from authentication bloc
    _userId = context.read<AuthenticationBloc>().state.user!.uid;

    // Initialize data loading
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _fetchUserData();
      _fetchRecords();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading data: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await _userRepository.getUserById(_userId);
      setState(() {
        userModel = userData;
      });

      // Update nutrition values in scanner controller
      if (userModel != null && userModel!.userInfo != null) {
        _scannerController.updateNutritionValues(
          maxCalories: userModel!.userInfo!.userMacros.calories ?? 0,
          maxFat: userModel!.userInfo!.userMacros.fat ?? 0,
          maxProtein: userModel!.userInfo!.userMacros.protein ?? 0,
          maxCarb: userModel!.userInfo!.userMacros.carbs ?? 0,
        );
      }
    } catch (e) {
      throw Exception('Failed to load user data: ${e.toString()}');
    }
  }

  void _fetchRecords() {
    _scannerController.getRecordByDate(_userId, _selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // Show loading state
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: MealAIColors.selectedTile,
        ),
      );
    }

    // Show error state
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(
                color: MealAIColors.blackText,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeData,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MealAIColors.selectedTile,
              ),
            ),
          ],
        ),
      );
    }

    // Show main content when data is loaded
    if (userModel == null) {
      return Center(
        child: Text(
          'User data not available',
          style: TextStyle(
            color: MealAIColors.blackText,
            fontSize: 16,
          ),
        ),
      );
    }

    // Main content
    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        _buildHeader(),
        SizedBox(height: 2.h),
        _buildDateScroller(),
        _buildNutritionTracker(),
        SizedBox(height: 2.h),
        _buildMealsList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF817C88),
            child: IconButton(
              icon: const Icon(Icons.person_outline),
              color: MealAIColors.whiteText,
              onPressed: () {},
            ),
          ),
        ),
        Text(
          'Nutrition Scanner',
          style: TextStyle(
              color: MealAIColors.whiteText,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
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
    );
  }

  Widget _buildDateScroller() {
    return Center(
      child: DateScroller(
        initialDate: userModel!.createdAt,
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
        selectedDateBackgroundColor: MealAIColors.selectedTile,
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
    );
  }

  Widget _buildNutritionTracker() {
    return GetBuilder<ScannerController>(
      builder: (controller) {
        return NutritionTrackerCard(
          maximumCalories: controller.maximumCalories.value,
          consumedCalories: controller.consumedCalories.value,
          burnedCalories: controller.burnedCalories.value,
          maximumFat: controller.maximumFat.value,
          consumedFat: controller.consumedFat.value,
          maximumProtein: controller.maximumProtein.value,
          consumedProtein: controller.consumedProtein.value,
          maximumCarb: controller.maximumCarb.value,
          consumedCarb: controller.consumedCarb.value,
        );
      },
    );
  }

  Widget _buildMealsList() {
    return Column(
      children: [
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
    );
  }
}
