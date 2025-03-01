import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:turfit/app/components/buttons.dart';
import 'package:turfit/app/components/height_picker.dart';
import 'package:turfit/app/components/tiles.dart';
import 'package:turfit/app/constants/colors.dart';
import 'package:turfit/app/models/Auth/user.dart';
import 'package:turfit/app/models/Onboarding/onboarding_model.dart';

class OnboardingQuestionaries extends StatefulWidget {
  const OnboardingQuestionaries({super.key});

  @override
  State<OnboardingQuestionaries> createState() =>
      _OnboardingQuestionariesState();
}

class _OnboardingQuestionariesState extends State<OnboardingQuestionaries> {
  final PageController _pageController = PageController();
  Gender _selectedGender = Gender.none;
  final int _totalPages = 12; // Total onboarding steps
  int _currentPage = 0;

  void _onNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() {
        _currentPage++;
      });
    }
  }

  DateTime selectedDate = DateTime(2000, 1, 1);

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
        description:
            "We'll use this to send you a special gift on your birthday.",
        widgetBuilder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
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
                onChange: (p0) {
                  print(p0);
                },
              )
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
              const SizedBox(height: 24),

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
