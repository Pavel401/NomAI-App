import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:turfit/app/components/buttons.dart';
import 'package:turfit/app/components/height_picker.dart';
import 'package:turfit/app/components/tiles.dart';
import 'package:turfit/app/components/weight_picker.dart';
import 'package:turfit/app/constants/colors.dart';
import 'package:turfit/app/constants/constants.dart';
import 'package:turfit/app/models/Auth/user.dart';
import 'package:turfit/app/models/Onboarding/onboarding_model.dart';
import 'package:turfit/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';

class OnboardingQuestionaries extends StatefulWidget {
  const OnboardingQuestionaries({super.key});

  @override
  State<OnboardingQuestionaries> createState() =>
      _OnboardingQuestionariesState();
}

class _OnboardingQuestionariesState extends State<OnboardingQuestionaries> {
  final PageController _pageController = PageController();
  Gender _selectedGender = Gender.none;
  final int _totalPages = 24; // Total number of steps
  int _currentPage = 0;

  // Define selection variables at the class level
  String selectedHaveYouTriedApps = "";
  String selectedWorkoutOption = "";
  String selectedGoal = "";
  String selectedPace = "";
  String selectedObstacle = "";
  String selectedDiet = "";
  String selectedMealTiming = "";
  List<String> selectedMeals = [];
  String selectedAllergy = "";
  String selectedEatOut = "";
  String selectedHomeCooked = "";
  String selectedActivityLevel = "";
  String selectedSleepPattern = "";
  TimeOfDay? firstMealOfDay;
  TimeOfDay? secondMealOfDay;
  TimeOfDay? thirdMealOfDay;
  DateTime selectedDate = DateTime(2000, 1, 1);
  String selectedDietKnowledge = "";
  String selectedBodySatisfaction = "";
  String selectedMacronutrientKnowledge = "";
  String? currentWeight;
  String? desiredWeight;
  String? currentHeight;
  void _onNext() {
    if (_isCurrentPageValid()) {
      if (_currentPage < _totalPages - 1) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
        setState(() {
          _currentPage++;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please make a selection to continue.")),
      );
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() {
        _currentPage--;
      });
    }
  }

  bool _isCurrentPageValid() {
    switch (_currentPage) {
      case 0:
        return _selectedGender != Gender.none;
      case 1:
        return selectedDate != DateTime(2000, 1, 1);
      case 2:
        return currentHeight != null;
      case 3:
        return currentWeight != null;
      case 4:
        return true; // Fun facts page, no validation needed
      case 5:
        return selectedHaveYouTriedApps.isNotEmpty;
      case 6:
        return selectedWorkoutOption.isNotEmpty;
      case 7:
        return selectedGoal.isNotEmpty;
      case 8:
        return desiredWeight != null;
      case 9:
        return selectedPace.isNotEmpty;
      case 10:
        return selectedObstacle.isNotEmpty;
      case 11:
        return selectedDietKnowledge.isNotEmpty;
      case 12:
        return selectedMeals.isNotEmpty;
      case 13:
        return selectedBodySatisfaction.isNotEmpty;
      case 14:
        return selectedDiet.isNotEmpty;
      case 15:
        return firstMealOfDay != null &&
            secondMealOfDay != null &&
            thirdMealOfDay != null;
      case 16:
        return selectedMacronutrientKnowledge.isNotEmpty;
      case 17:
        return true; // Track what you eat page, no validation needed
      case 18:
        return selectedAllergy.isNotEmpty;
      case 19:
        return selectedEatOut.isNotEmpty;
      case 20:
        return selectedHomeCooked.isNotEmpty;
      case 21:
        return selectedActivityLevel.isNotEmpty;
      case 22:
        return selectedSleepPattern.isNotEmpty;
      default:
        return true;
    }
  }

  List<OnboardingModel> getOnboardingModels() {
    return [
      OnboardingModel(
        title: "Choose Your Gender",
        description: "This will help us provide the best recommendations.",
        widgetBuilder: (context) {
          List<Gender> genders = [Gender.male, Gender.female, Gender.other];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...genders.map(
                (gender) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: gender.toSimpleText(),
                    isSelected: _selectedGender == gender,
                    onTap: () {
                      setState(() {
                        _selectedGender = gender;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "When is your birthday?",
        description: "This will help us create a personalized plan for you.",
        widgetBuilder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("D.O.B",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                ],
              ),
              SizedBox(height: 5.h),
              SizedBox(
                height: 25.h,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      selectedDate = newDate;
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "Height",
        description: "This will help us create a personalized plan for you.",
        widgetBuilder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HeightPicker(
                onChange: (height) {
                  setState(() {
                    currentHeight = height;
                  });
                },
              )
            ],
          );
        },
      ),
      OnboardingModel(
        title: "Weight",
        description: "This will help us create a personalized plan for you.",
        widgetBuilder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WeightPicker(
                onChange: (weight) {
                  setState(() {
                    currentWeight = weight;
                  });
                },
              )
            ],
          );
        },
      ),
      OnboardingModel(
        title: AppConstants.appName,
        description: "Let's get started with some fun facts about nutrition.",
        widgetBuilder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 60,
              ),
              SizedBox(height: 2.h),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Did you know?",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: MealAIColors.blackText,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppConstants.getRandomFunFact(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "Have you tried any other calorie tracking apps?",
        description: "",
        widgetBuilder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: PrimaryIconTile(
                  icon: Icons.thumb_up_sharp,
                  title: "Yes",
                  isSelected: selectedHaveYouTriedApps == "Yes",
                  onTap: () {
                    setState(() {
                      selectedHaveYouTriedApps = "Yes";
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: PrimaryIconTile(
                  icon: Icons.thumb_down_sharp,
                  title: "No",
                  isSelected: selectedHaveYouTriedApps == "No",
                  onTap: () {
                    setState(() {
                      selectedHaveYouTriedApps = "No";
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "How many workouts do you do per week?",
        description: "This will help us tailor your plan.",
        widgetBuilder: (context) {
          List<String> workoutOptions = ["0-2", "3-5", "6+"];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...workoutOptions.map(
                (option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: option,
                    isSelected: selectedWorkoutOption == option,
                    onTap: () {
                      setState(() {
                        selectedWorkoutOption = option;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "What is your goal?",
        description: "Choose your primary fitness goal.",
        widgetBuilder: (context) {
          List<String> goals = ["Gain Weight", "Maintain", "Lose Weight"];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...goals.map(
                (goal) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: goal,
                    isSelected: selectedGoal == goal,
                    onTap: () {
                      setState(() {
                        selectedGoal = goal;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "Choose your desired weight",
        description: "Set a target weight goal.",
        widgetBuilder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WeightPicker(
                onChange: (weight) {
                  setState(() {
                    desiredWeight = weight;
                  });
                },
              )
            ],
          );
        },
      ),
      OnboardingModel(
        title: "How fast do you want to reach your goal?",
        description: "Select your preferred pace.",
        widgetBuilder: (context) {
          List<String> paces = ["Slow", "Moderate", "Fast"];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...paces.map(
                (pace) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: pace,
                    isSelected: selectedPace == pace,
                    onTap: () {
                      setState(() {
                        selectedPace = pace;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "What's stopping you from reaching your goal?",
        description: "Identify any obstacles.",
        widgetBuilder: (context) {
          List<String> obstacles = [
            "Lack of time",
            "Motivation",
            "Knowledge",
            "Other"
          ];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...obstacles.map(
                (obstacle) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: obstacle,
                    isSelected: selectedObstacle == obstacle,
                    onTap: () {
                      setState(() {
                        selectedObstacle = obstacle;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title:
            "Do you know the relationship between your diet and your health?",
        description: "",
        widgetBuilder: (context) {
          List<String> options = [
            "Yes - I understand the importance of a balanced diet",
            "A little - I know some basics",
            "No - I am not sure how diet affects health",
          ];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...options.map(
                (option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: option,
                    isSelected: selectedDietKnowledge == option,
                    onTap: () {
                      setState(() {
                        selectedDietKnowledge = option;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "Which of the following habits do you have?",
        description: "",
        widgetBuilder: (context) {
          List<String> habits = [
            "I have sweet tooth",
            "I like junk food",
            "I don't drink enough water",
            "I eat late at night",
            "I eat salty snacks",
            "I consume too much caffeine",
          ];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...habits.map(
                (habit) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: habit,
                    isSelected: selectedMeals.contains(habit),
                    onTap: () {
                      setState(() {
                        if (selectedMeals.contains(habit)) {
                          selectedMeals.remove(habit);
                        } else {
                          selectedMeals.add(habit);
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "Do you relate to the statement below?",
        description:
            "I feel dissatisfied with my body when I look in the mirror.",
        widgetBuilder: (context) {
          List<String> options = [
            "Strongly Agree",
            "Agree",
            "Neutral",
            "Disagree",
            "Strongly Disagree",
          ];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...options.map(
                (option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: option,
                    isSelected: selectedBodySatisfaction == option,
                    onTap: () {
                      setState(() {
                        selectedBodySatisfaction = option;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "Do you follow any specific diet?",
        description: "Select your diet preferences.",
        widgetBuilder: (context) {
          List<String> diets = [
            "Vegan",
            "Vegetarian",
            "Non-Vegetarian",
            "Mediterranean",
            "Keto",
            "Paleo",
            "Other"
          ];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 8.0, // Space between chips
                runSpacing: 8.0, // Space between lines
                alignment: WrapAlignment.center,
                children: diets.map((diet) {
                  return ChoiceChip(
                    label: Text(
                      diet,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: selectedDiet == diet
                                ? MealAIColors.whiteText
                                : MealAIColors.blackText,
                          ),
                    ),
                    selected: selectedDiet == diet,
                    selectedColor:
                        MealAIColors.selectedTile, // Color when selected
                    checkmarkColor:
                        MealAIColors.whiteText, // Color of the checkmark
                    onSelected: (selected) {
                      setState(() {
                        selectedDiet = diet;
                      });
                    },
                  );
                }).toList(),
              )
            ],
          );
        },
      ),
      OnboardingModel(
        title: "Do you typically eat your meals at the same time?",
        description: "Let us know your meal timing preferences.",
        widgetBuilder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MealTimePicker(
                title: "First Meal",
                isSelected: firstMealOfDay != null,
                icon: Icons.schedule,
                onTimeChanged: (TimeOfDay? time) {
                  if (time != null) {
                    setState(() {
                      firstMealOfDay = time;
                    });
                  }
                },
              ),
              MealTimePicker(
                title: "Second Meal",
                isSelected: secondMealOfDay != null,
                icon: Icons.schedule,
                onTimeChanged: (TimeOfDay? time) {
                  if (time != null) {
                    setState(() {
                      secondMealOfDay = time;
                    });
                  }
                },
              ),
              MealTimePicker(
                title: "Third Meal",
                isSelected: thirdMealOfDay != null,
                icon: Icons.schedule,
                onTimeChanged: (TimeOfDay? time) {
                  if (time != null) {
                    setState(() {
                      thirdMealOfDay = time;
                    });
                  }
                },
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "Do you know the macronutrient values of what you eat?",
        description: "",
        widgetBuilder: (context) {
          List<String> options = [
            "Yes - I know the macronutrient values",
            "A little - I know some basics",
            "No - I am not sure what macronutrients are",
          ];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...options.map(
                (option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: option,
                    isSelected: selectedMacronutrientKnowledge == option,
                    onTap: () {
                      setState(() {
                        selectedMacronutrientKnowledge = option;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "Track what you eat, instantly",
        description:
            "Snap a photo or log your meals to keep track of your nutrition.",
        widgetBuilder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                size: 60,
              ),
              SizedBox(height: 2.h),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "Do you have any food allergies?",
        description: "Let us know about any food allergies.",
        widgetBuilder: (context) {
          List<String> allergies = [
            "None",
            "Gluten",
            "Lactose",
            "Nuts",
            "Other"
          ];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...allergies.map(
                (allergy) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: allergy,
                    isSelected: selectedAllergy == allergy,
                    onTap: () {
                      setState(() {
                        selectedAllergy = allergy;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "How often do you eat out?",
        description: "Select how frequently you dine out.",
        widgetBuilder: (context) {
          List<String> eatOutOptions = [
            "Never",
            "Rarely",
            "Sometimes",
            "Often"
          ];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...eatOutOptions.map(
                (option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: option,
                    isSelected: selectedEatOut == option,
                    onTap: () {
                      setState(() {
                        selectedEatOut = option;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "Do you prefer home-cooked meals?",
        description: "Let us know your preference for home-cooked meals.",
        widgetBuilder: (context) {
          List<String> homeCookedOptions = ["Yes", "No"];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...homeCookedOptions.map(
                (option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: option,
                    isSelected: selectedHomeCooked == option,
                    onTap: () {
                      setState(() {
                        selectedHomeCooked = option;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "What is your activity level?",
        description: "Select your daily activity level.",
        widgetBuilder: (context) {
          List<String> activityLevels = [
            "Sedentary",
            "Lightly Active",
            "Moderately Active",
            "Very Active"
          ];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...activityLevels.map(
                (level) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: level,
                    isSelected: selectedActivityLevel == level,
                    onTap: () {
                      setState(() {
                        selectedActivityLevel = level;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "What is your sleep pattern like?",
        description: "Select your typical sleep pattern.",
        widgetBuilder: (context) {
          List<String> sleepPatterns = [
            "Less than 6 hours",
            "6-8 hours",
            "More than 8 hours"
          ];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...sleepPatterns.map(
                (pattern) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: pattern,
                    isSelected: selectedSleepPattern == pattern,
                    onTap: () {
                      setState(() {
                        selectedSleepPattern = pattern;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      OnboardingModel(
        title: "Sign Up with Google",
        description: "Create an account to save your progress",
        widgetBuilder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context
                      .read<AuthenticationBloc>()
                      .add(GoogleSignInRequested());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image.asset(
                    //   'assets/google_logo.png', // Add your Google logo asset
                    //   height: 24,
                    // ),
                    SizedBox(width: 8),
                    Text("Sign Up with Google"),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<OnboardingModel> onboardingModels = getOnboardingModels();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            children: [
              /// **Progress Indicator (Single Continuous Line)**
              Stack(
                children: [
                  /// Background Track
                  Container(
                    width: double.infinity,
                    height: 6,
                    decoration: BoxDecoration(
                      color: MealAIColors.stepperColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),

                  /// Progress Bar (Filling)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: (constraints.maxWidth / (_totalPages - 1)) *
                            _currentPage,
                        height: 6,
                        decoration: BoxDecoration(
                          color: MealAIColors.selectedTile,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 4.h),

              /// **Title & Description**
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    onboardingModels[_currentPage].title,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    onboardingModels[_currentPage].description,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              /// **PageView for Onboarding Steps**
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  //   physics: const NeverScrollableScrollPhysics(),
                  itemCount: onboardingModels.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) =>
                      onboardingModels[index].widgetBuilder(context),
                ),
              ),

              /// **Next Button**
              const SizedBox(height: 20),
              PrimaryButton(tile: "Next", onPressed: _onNext),
            ],
          ),
        ),
      ),
    );
  }
}
