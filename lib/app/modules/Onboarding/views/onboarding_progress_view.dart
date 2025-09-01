import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/components/buttons.dart';
import 'package:NomAi/app/components/height_picker.dart';
import 'package:NomAi/app/components/tiles.dart';
import 'package:NomAi/app/components/weight_picker.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/constants/constants.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/models/Onboarding/onboarding_model.dart';
import 'package:NomAi/app/modules/Onboarding/views/calorie_required.dart';
import 'package:NomAi/app/utility/user_utility.dart';

class OnboardingQuestionaries extends StatefulWidget {
  const OnboardingQuestionaries({super.key});

  @override
  State<OnboardingQuestionaries> createState() =>
      _OnboardingQuestionariesState();
}

class _OnboardingQuestionariesState extends State<OnboardingQuestionaries> {
  final PageController _pageController = PageController();
  Gender _selectedGender = Gender.none;
  final int _totalPages = 22; // Total number of steps
  int _currentPage = 0;

  DateTime birthday = DateTime(1990, 1, 1);
  WeeklyPace selectedPace = WeeklyPace.none;
  String? currentHeight = "";
  String? currentWeight = "";
  String? desiredWeight = "";
  String selectedHaveYouTriedApps = "";
  String selectedWorkoutOption = "";
  HealthMode selectedGoal = HealthMode.none;
  String selectedObstacle = "";
  String selectedDietKnowledge = "";
  List<String> selectedMeals = [
    "",
    "",
  ];
  String selectedBodySatisfaction = "";
  String selectedDiet = "";
  String selectedMealTiming = "";
  TimeOfDay? firstMealOfDay = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay? secondMealOfDay = TimeOfDay(hour: 12, minute: 0);
  TimeOfDay? thirdMealOfDay = TimeOfDay(hour: 18, minute: 0);
  String selectedMacronutrientKnowledge = "";
  List<String> selectedAllergies = [];
  String selectedEatOut = "";
  String selectedHomeCooked = "";
  ActivityLevel selectedActivityLevel = ActivityLevel.none;
  String selectedSleepPattern = "";

  late ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_isCurrentPageValid()) {
      if (_currentPage < _totalPages - 1) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
        setState(() {
          _currentPage++;
        });
      } else {
        int age = EnhancedUserNutrition.calculateAccurateAge(birthday);

        double heightInCm = convertHeightToCm(currentHeight!);

        double weightInKg = convertWeightToKg(currentWeight!);

        double desiredWeightInKg = convertWeightToKg(desiredWeight!);

        UserBasicInfo info = UserBasicInfo(
          selectedGender: _selectedGender,
          userMacros: UserMacros(calories: 0, protein: 0, carbs: 0, fat: 0),
          birthDate: birthday,
          age: age,
          currentHeight: heightInCm,
          currentWeight: weightInKg,
          desiredWeight: desiredWeightInKg,
          selectedHaveYouTriedApps: selectedHaveYouTriedApps,
          selectedWorkoutOption: selectedWorkoutOption,
          selectedGoal: selectedGoal,
          selectedPace: selectedPace,
          selectedObstacle: selectedObstacle,
          selectedDietKnowledge: selectedDietKnowledge,
          selectedMeals: selectedMeals,
          selectedBodySatisfaction: selectedBodySatisfaction,
          selectedDiet: selectedDiet,
          selectedMealTiming: selectedMealTiming,
          firstMealOfDay: firstMealOfDay,
          secondMealOfDay: secondMealOfDay,
          thirdMealOfDay: thirdMealOfDay,
          selectedMacronutrientKnowledge: selectedMacronutrientKnowledge,
          selectedAllergies: selectedAllergies,
          selectedEatOut: selectedEatOut,
          selectedHomeCooked: selectedHomeCooked,
          selectedActivityLevel: selectedActivityLevel,
          selectedSleepPattern: selectedSleepPattern,
        );

        final myUser = UserModel(
            userId: "",
            userInfo: info,
            email: "",
            name: "",
            photoUrl: "",
            phoneNumber: "",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now());

        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return DailyCalorieRequired(
              userBasicInfo: info,
            );
          },
        ));
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
        return birthday != DateTime(2000, 1, 1);
      case 2:
        return currentHeight != null && currentHeight!.isNotEmpty;
      case 3:
        return currentWeight != null && currentWeight!.isNotEmpty;
      case 4:
        return true;
      case 5:
        return selectedHaveYouTriedApps.isNotEmpty;
      case 6:
        return selectedWorkoutOption.isNotEmpty;
      case 7:
        return selectedGoal != HealthMode.none;

      case 8:
        return desiredWeight != null && desiredWeight!.isNotEmpty;

      case 9:
        return selectedPace != WeeklyPace.none;

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
        return selectedAllergies.isNotEmpty;

      case 19:
        return selectedEatOut.isNotEmpty;

      case 20:
        return selectedHomeCooked.isNotEmpty;

      case 21:
        return selectedActivityLevel != ActivityLevel.none;

      default:
        return true;
    }
  }

  void _populateDemoData() {
    setState(() {
      _selectedGender = Gender.male;
      birthday = DateTime(2002, 5, 5);
      currentHeight = "180 cm";
      currentWeight = "112 kg";
      desiredWeight = "80 kg";
      selectedHaveYouTriedApps = "Yes";
      selectedWorkoutOption = "3-5";
      selectedGoal = HealthMode.weightLoss;
      selectedPace = WeeklyPace.moderate;
      selectedObstacle = "Lack of time";
      selectedDietKnowledge =
          "Yes - I understand the importance of a balanced diet";
      selectedMeals = ["I have sweet tooth", "I like junk food"];
      selectedBodySatisfaction = "Neutral";
      selectedDiet = "Vegan";
      selectedMealTiming = "Regular";
      firstMealOfDay = TimeOfDay(hour: 8, minute: 0);
      secondMealOfDay = TimeOfDay(hour: 12, minute: 0);
      thirdMealOfDay = TimeOfDay(hour: 18, minute: 0);
      selectedMacronutrientKnowledge = "Yes - I know the macronutrient values";
      selectedAllergies = ["None"];
      selectedEatOut = "Rarely";
      selectedHomeCooked = "Yes";
      selectedActivityLevel = ActivityLevel.moderatelyActive;
      selectedSleepPattern = "6-8 hours";

      _currentPage = _totalPages - 1;
      _pageController.jumpToPage(_currentPage);

      if (_currentPage == _totalPages - 1) {
        _onNext();
      }
    });
  }

  List<OnboardingModel> getOnboardingModels() {
    return [
      OnboardingModel(
        title: "Choose Your Gender",
        description: "",
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
        description: "",
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
                  initialDateTime: birthday,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      birthday = newDate;
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
                initialHeight: currentHeight,
                onChange: (height) {
                  setState(() {
                    currentHeight = height;
                  });
                  print(currentHeight);
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
                initialWeight: currentWeight,
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
          List<HealthMode> goals = [
            HealthMode.weightLoss,
            HealthMode.maintainWeight,
            HealthMode.muscleGain,
          ];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...goals.map(
                (goal) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: goal.toSimpleText(),
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
        title: "What is your desired weight ?",
        description: "We will use this to create your personalized plan.",
        widgetBuilder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WeightPicker(
                initialWeight: desiredWeight,
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
          Map<WeeklyPace, Map<String, String>> paces = {
            WeeklyPace.slow: {
              "title": "Slow - 0.1 kg/week",
              "description":
                  "I'm in no rush. I want to take it slow and steady."
            },
            WeeklyPace.moderate: {
              "title": "Moderate - 0.5 kg/week",
              "description": "I want to see results, but I'm not in a hurry."
            },
            WeeklyPace.fast: {
              "title": "Fast - 1 kg/week",
              "description":
                  "Accelerated results requiring dedicated lifestyle modifications."
            },
          };
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...paces.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SecondaryTile(
                    title: entry.value["title"]!,
                    description: entry.value["description"]!,
                    isSelected: selectedPace == entry.key,
                    onTap: () {
                      setState(() {
                        selectedPace = entry.key;
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
                      if (selected) {
                        setState(() {
                          selectedDiet = diet;
                        });
                      } else {
                        setState(() {
                          selectedDiet = ""; // Deselect the chip
                        });
                      }
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
        description: "Select all that apply to you.",
        widgetBuilder: (context) {
          List<String> allergies = [
            "None",
            "Gluten",
            "Lactose",
            "Nuts",
            "Eggs",
            "Shellfish",
            "Soy",
            "Fish",
            "Other"
          ];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 8.0, // Space between chips
                runSpacing: 8.0, // Space between lines
                alignment: WrapAlignment.center,
                children: allergies.map((allergy) {
                  return FilterChip(
                    label: Text(
                      allergy,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: selectedAllergies.contains(allergy)
                                ? MealAIColors.whiteText
                                : MealAIColors.blackText,
                          ),
                    ),
                    selected: selectedAllergies.contains(allergy),
                    selectedColor: MealAIColors.selectedTile,
                    checkmarkColor: MealAIColors.whiteText,
                    onSelected: (selected) {
                      setState(() {
                        if (allergy == "None") {
                          if (selectedAllergies.contains("None")) {
                            selectedAllergies.remove("None");
                          } else {
                            selectedAllergies.clear();
                            selectedAllergies.add("None");
                          }
                        } else {
                          if (selectedAllergies.contains("None")) {
                            selectedAllergies.remove("None");
                          }
                          if (selectedAllergies.contains(allergy)) {
                            selectedAllergies.remove(allergy);
                          } else {
                            selectedAllergies.add(allergy);
                          }
                          if (selectedAllergies.isEmpty) {
                            selectedAllergies.add("None");
                          }
                        }
                      });
                    },
                  );
                }).toList(),
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
          List<ActivityLevel> activityLevels = [
            ActivityLevel.sedentary,
            ActivityLevel.lightlyActive,
            ActivityLevel.moderatelyActive,
            ActivityLevel.veryActive
          ];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...activityLevels.map(
                (level) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryTile(
                    title: level.toSimpleText(),
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
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_currentPage == 0) {
                        Navigator.of(context)
                            .pop(); // Close the onboarding if on first page
                      } else {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MealAIColors.stepperColor,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: MealAIColors.blackText,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: LinearProgressBar(
                      maxSteps: _totalPages,
                      progressType: LinearProgressBar.progressTypeLinear,
                      currentStep: _currentPage,
                      progressColor: MealAIColors.blackText,
                      backgroundColor: MealAIColors.stepperColor,
                      minHeight: 0.5.h,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return PageView.builder(
                      controller: _pageController,
                      itemCount: onboardingModels.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) =>
                          onboardingModels[index].widgetBuilder(context),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                tile:
                    _currentPage == _totalPages - 1 ? "Go to Sign Up" : "Next",
                onPressed: () {
                  // _populateDemoData();
                  _onNext();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Path drawStar(Size size) {
  double degToRad(double deg) => deg * (3.1415926535897932 / 180.0);

  const numberOfPoints = 5;
  final halfWidth = size.width / 2;
  final externalRadius = halfWidth;
  final internalRadius = halfWidth / 2.5;
  final degreesPerStep = degToRad(360 / numberOfPoints);
  final halfDegreesPerStep = degreesPerStep / 2;
  final path = Path();
  final fullAngle = degToRad(360);
  path.moveTo(size.width, halfWidth);

  for (double step = 0; step < fullAngle; step += degreesPerStep) {
    path.lineTo(halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step));
    path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep));
  }
  path.close();
  return path;
}
