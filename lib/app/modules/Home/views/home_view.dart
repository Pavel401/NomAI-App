import 'package:NomAi/app/components/empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:timeline_date_picker_plus/timeline_date_picker_plus.dart';
import 'package:NomAi/app/components/nutritionTrackerCard.dart'
    show NutritionTrackerCard;
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/constants/enums.dart';
import 'package:NomAi/app/models/AI/nutrition_record.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_event.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_state.dart';
import 'package:NomAi/app/modules/Home/component/nutrition_card.dart';
import 'package:NomAi/app/modules/Home/views/nutrition_view.dart';
import 'package:NomAi/app/modules/Scanner/controller/scanner_controller.dart';
import 'package:NomAi/app/modules/Settings/views/settings.dart';
import 'package:NomAi/app/repo/firebase_user_repo.dart';
import 'package:NomAi/app/repo/nutrition_record_repo.dart';
import 'package:NomAi/app/utility/registry_service.dart';

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
    _scannerController = Get.put(ScannerController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authState = context.read<AuthenticationBloc>().state;
      if (authState.user == null) {
        setState(() {
          _errorMessage = 'User not authenticated. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      _userId = authState.user!.uid;

      UserBloc? userBloc;
      try {
        userBloc = context.read<UserBloc>();
      } catch (e) {
        setState(() {
          _errorMessage =
              'UserBloc not found in context. Please restart the app.';
          _isLoading = false;
        });
        return;
      }

      final userState = userBloc.state;

      if (userState is UserLoaded) {
        setState(() {
          userModel = userState.userModel;
          _isLoading = false;
        });
        // Sync controller's selected date with current selection
        _scannerController.selectedDate = _selectedDate;
        _updateNutritionValues(userState.userModel);
        _fetchRecords();
      } else {
        userBloc.add(LoadUserModel(_userId));

        await for (final state in userBloc.stream) {
          if (state is UserLoaded) {
            setState(() {
              userModel = state.userModel;
              _isLoading = false;
            });
            // Sync controller's selected date with current selection
            _scannerController.selectedDate = _selectedDate;
            _updateNutritionValues(state.userModel);
            _fetchRecords();
            break;
          } else if (state is UserError) {
            setState(() {
              _errorMessage = 'Failed to load user data: ${state.message}';
              _isLoading = false;
            });
            break;
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  void _fetchRecords() {
    if (_userId.isNotEmpty) {
      _scannerController.getRecordByDate(
          _userId, _scannerController.selectedDate);
    }
  }

  void _updateNutritionValues(UserModel? userModel) {
    if (userModel != null && userModel.userInfo != null) {
      _scannerController.updateNutritionValues(
        maxCalories: userModel.userInfo!.userMacros.calories,
        maxFat: userModel.userInfo!.userMacros.fat,
        maxProtein: userModel.userInfo!.userMacros.protein,
        maxCarb: userModel.userInfo!.userMacros.carbs,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MealAIColors.blueGrey,
        elevation: 0,
        title: Text(
          'NomAI',
          style: TextStyle(
            color: MealAIColors.whiteText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Bounceable(
              onTap: () {
                Get.to(() => SettingsView());
              },
              child: CircleAvatar(
                backgroundColor: const Color(0xFF817C88),
                child: Icon(Icons.settings_outlined,
                    color: MealAIColors.whiteText),
              ),
            ),
          ),
        ],
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
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: MealAIColors.selectedTile,
        ),
      );
    }

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

    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        // _buildHeader(),
        SizedBox(height: 2.h),
        _buildDateScroller(),
        _buildNutritionTracker(),
        SizedBox(height: 2.h),
        _buildMealsList(),
      ],
    );
  }

  // Widget _buildHeader() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: Text(
  //           'NomAI',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //             color: MealAIColors.whiteText,
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ),
  //       Padding(
  //         padding: EdgeInsets.only(right: 4.w),
  //         child: Bounceable(
  //           onTap: () {
  //             Get.to(() => SettingsView());
  //           },
  //           child: CircleAvatar(
  //             backgroundColor: const Color(0xFF817C88),
  //             child:
  //                 Icon(Icons.settings_outlined, color: MealAIColors.whiteText),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildDateScroller() {
    // Show a 30-day window for the current month
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfRange = startOfMonth.add(const Duration(days: 29));

    // Ensure selected date stays within the 30-day window
    final clampedSelectedDate = _selectedDate.isBefore(startOfMonth)
        ? startOfMonth
        : (_selectedDate.isAfter(endOfRange) ? endOfRange : _selectedDate);

    return Center(
      child: DateScroller(
        initialDate: startOfMonth,
        lastDate: endOfRange,
        selectedDate: clampedSelectedDate,
        showMonthName: false,
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
          });

          _scannerController.selectedDate = _selectedDate;

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
              Text(
                "Recently Eaten",
                style: TextStyle(
                  color: MealAIColors.blackText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EmptyIllustrations(
                    removeHeightValue: true,
                    title: "No meals recorded",
                    message: "Start tracking your nutrition",
                    imagePath: "assets/svg/empty.svg",
                    width: 50.w,
                    height: 40.h,
                  )
                ],
              );
            }

            return ListView.builder(
              itemCount: controller.dailyRecords.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
              itemBuilder: (context, index) {
                NutritionRecord record = controller.dailyRecords[index];
                final isFailed = record.processingStatus == ProcessingStatus.FAILED;

                if (isFailed) {
                  return Dismissible(
                    key: Key(record.recordTime.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: MealAIColors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    onDismissed: (direction) async {
                      final nutritionRecordRepo = serviceLocator<NutritionRecordRepo>();
                      final recordTime = record.recordTime ?? DateTime.now();

                      await nutritionRecordRepo.deleteMealEntryByTime(
                        _userId,
                        recordTime,
                        recordTime,
                      );

                      await _scannerController.getRecordByDate(_userId, _selectedDate);
                    },
                    child: NutritionCard(
                      nutritionRecord: record,
                      userModel: userModel!,
                    ),
                  );
                }

                return NutritionCard(
                  nutritionRecord: record,
                  userModel: userModel!,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
