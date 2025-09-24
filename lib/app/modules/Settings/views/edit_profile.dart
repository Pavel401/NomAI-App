import 'package:flutter/material.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/repo/firebase_user_repo.dart';
import 'package:NomAi/app/components/buttons.dart';

class EditUserBasicInfoView extends StatefulWidget {
  final UserBasicInfo userBasicInfo;
  final UserModel userModel;

  const EditUserBasicInfoView({
    super.key,
    required this.userBasicInfo,
    required this.userModel,
  });

  @override
  State<EditUserBasicInfoView> createState() => _EditUserBasicInfoViewState();
}

class _EditUserBasicInfoViewState extends State<EditUserBasicInfoView> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  late TextEditingController _heightController;
  late TextEditingController _currentWeightController;
  late TextEditingController _desiredWeightController;
  late TextEditingController _ageController;

  late Gender _selectedGender;
  late DateTime _birthDate;
  late WeeklyPace _selectedPace;
  late HealthMode _selectedGoal;
  late ActivityLevel _selectedActivityLevel;
  late String _selectedHaveYouTriedApps;
  late String _selectedWorkoutOption;
  late String _selectedObstacle;
  late String _selectedDietKnowledge;
  late List<String> _selectedMeals;
  late String _selectedBodySatisfaction;
  late String _selectedDiet;
  late String _selectedMealTiming;
  late TimeOfDay? _firstMealOfDay;
  late TimeOfDay? _secondMealOfDay;
  late TimeOfDay? _thirdMealOfDay;
  late String _selectedMacronutrientKnowledge;
  late List<String> _selectedAllergies;
  late String _selectedEatOut;
  late String _selectedHomeCooked;
  late String _selectedSleepPattern;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    final info = widget.userBasicInfo;

    _heightController = TextEditingController(
      text: info.currentHeight?.toString() ?? '',
    );
    _currentWeightController = TextEditingController(
      text: info.currentWeight?.toString() ?? '',
    );
    _desiredWeightController = TextEditingController(
      text: info.desiredWeight?.toString() ?? '',
    );
    _ageController = TextEditingController(
      text: info.age.toString(),
    );

    _selectedGender = info.selectedGender;
    _birthDate = info.birthDate;
    _selectedPace = info.selectedPace;
    _selectedGoal = info.selectedGoal;
    _selectedActivityLevel = info.selectedActivityLevel;
    _selectedHaveYouTriedApps = info.selectedHaveYouTriedApps;
    _selectedWorkoutOption = info.selectedWorkoutOption;
    _selectedObstacle = info.selectedObstacle;
    _selectedDietKnowledge = info.selectedDietKnowledge;
    _selectedMeals = List.from(info.selectedMeals);
    _selectedBodySatisfaction = info.selectedBodySatisfaction;
    _selectedDiet = info.selectedDiet;
    _selectedMealTiming = info.selectedMealTiming;
    _firstMealOfDay = info.firstMealOfDay;
    _secondMealOfDay = info.secondMealOfDay;
    _thirdMealOfDay = info.thirdMealOfDay;
    _selectedMacronutrientKnowledge = info.selectedMacronutrientKnowledge;
    _selectedAllergies = info.selectedAllergies;
    _selectedEatOut = info.selectedEatOut;
    _selectedHomeCooked = info.selectedHomeCooked;
    _selectedSleepPattern = info.selectedSleepPattern;
  }

  @override
  void dispose() {
    _heightController.dispose();
    _currentWeightController.dispose();
    _desiredWeightController.dispose();
    _ageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MealAIColors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: MealAIColors.blackText,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(color: MealAIColors.blackText),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: MealAIColors.blackText),
          suffixText: suffix,
          suffixStyle: TextStyle(color: MealAIColors.blackText),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MealAIColors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MealAIColors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MealAIColors.black, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MealAIColors.red),
          ),
          contentPadding: const EdgeInsets.all(16),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: MealAIColors.blackText),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MealAIColors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MealAIColors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MealAIColors.black, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
          filled: true,
          fillColor: Colors.white,
        ),
        dropdownColor: Colors.white,
        style: TextStyle(color: MealAIColors.blackText),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabel(item),
              style: TextStyle(color: MealAIColors.blackText),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        icon: Icon(Icons.keyboard_arrow_down, color: MealAIColors.blackText),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime selectedDate,
    required void Function(DateTime) onDateSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: MealAIColors.black,
                    onPrimary: Colors.white,
                    onSurface: MealAIColors.blackText,
                    surface: Colors.white,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: MealAIColors.blackText,
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            onDateSelected(picked);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: MealAIColors.grey),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: MealAIColors.blackText,
                ),
              ),
              Row(
                children: [
                  Text(
                    "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}",
                    style: TextStyle(
                      fontSize: 16,
                      color: MealAIColors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.calendar_today,
                    color: MealAIColors.blackText,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? selectedTime,
    required void Function(TimeOfDay?) onTimeSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: selectedTime ?? const TimeOfDay(hour: 8, minute: 0),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: MealAIColors.black,
                    onPrimary: Colors.white,
                    onSurface: MealAIColors.blackText,
                    surface: Colors.white,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: MealAIColors.blackText,
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );
          onTimeSelected(picked);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: MealAIColors.grey),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: MealAIColors.blackText,
                ),
              ),
              Row(
                children: [
                  Text(
                    selectedTime?.format(context) ?? "Not selected",
                    style: TextStyle(
                      fontSize: 16,
                      color: MealAIColors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.access_time,
                    color: MealAIColors.blackText,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelect({
    required String label,
    required List<String> options,
    required List<String> selectedValues,
    required void Function(List<String>) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MealAIColors.blackText,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedValues.contains(option);
              return FilterChip(
                label: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : MealAIColors.blackText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  final newValues = List<String>.from(selectedValues);
                  if (selected) {
                    newValues.add(option);
                  } else {
                    newValues.remove(option);
                  }
                  onChanged(newValues);
                },
                backgroundColor: Colors.white,
                selectedColor: MealAIColors.black,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? MealAIColors.black : MealAIColors.grey,
                ),
                elevation: 0,
                pressElevation: 1,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _saveUserInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedUserBasicInfo = widget.userBasicInfo.copyWith(
        selectedGender: _selectedGender,
        age: int.tryParse(_ageController.text) ?? widget.userBasicInfo.age,
        birthDate: _birthDate,
        currentHeight: double.tryParse(_heightController.text),
        currentWeight: double.tryParse(_currentWeightController.text),
        desiredWeight: double.tryParse(_desiredWeightController.text),
        selectedPace: _selectedPace,
        selectedGoal: _selectedGoal,
        selectedActivityLevel: _selectedActivityLevel,
        selectedHaveYouTriedApps: _selectedHaveYouTriedApps,
        selectedWorkoutOption: _selectedWorkoutOption,
        selectedObstacle: _selectedObstacle,
        selectedDietKnowledge: _selectedDietKnowledge,
        selectedMeals: _selectedMeals,
        selectedBodySatisfaction: _selectedBodySatisfaction,
        selectedDiet: _selectedDiet,
        selectedMealTiming: _selectedMealTiming,
        firstMealOfDay: _firstMealOfDay,
        secondMealOfDay: _secondMealOfDay,
        thirdMealOfDay: _thirdMealOfDay,
        selectedMacronutrientKnowledge: _selectedMacronutrientKnowledge,
        // selectedAllergy: _selectedAllergy,
        selectedAllergies: _selectedAllergies,
        selectedEatOut: _selectedEatOut,
        selectedHomeCooked: _selectedHomeCooked,
        selectedSleepPattern: _selectedSleepPattern,
      );

      final updatedUserModel = widget.userModel.copyWith(
        userInfo: updatedUserBasicInfo,
      );

      final firebaseUserRepo = FirebaseUserRepo();
      await firebaseUserRepo.updateUserData(updatedUserModel);

      if (mounted) {
        Navigator.pop(context, updatedUserBasicInfo);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Profile updated successfully!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: MealAIColors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to update profile. Please try again.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: MealAIColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: MealAIColors.blackText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: MealAIColors.blackText,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSection('Personal Information', [
                _buildDropdown<Gender>(
                  label: 'Gender',
                  value: _selectedGender,
                  items: Gender.values,
                  itemLabel: (gender) => gender.toSimpleText(),
                  onChanged: (value) =>
                      setState(() => _selectedGender = value!),
                ),
                _buildTextField(
                  label: 'Age (years)',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 1 || age > 120) {
                      return 'Please enter a valid age (1-120)';
                    }
                    return null;
                  },
                ),
                _buildDatePicker(
                  label: 'Date of Birth',
                  selectedDate: _birthDate,
                  onDateSelected: (date) => setState(() => _birthDate = date),
                ),
              ]),
              _buildSection('Physical Measurements', [
                _buildTextField(
                  label: 'Height',
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  suffix: 'cm',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your height';
                    }
                    final height = double.tryParse(value);
                    if (height == null || height < 100 || height > 250) {
                      return 'Please enter a valid height (100-250 cm)';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'Current Weight',
                  controller: _currentWeightController,
                  keyboardType: TextInputType.number,
                  suffix: 'kg',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current weight';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight < 30 || weight > 300) {
                      return 'Please enter a valid weight (30-300 kg)';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'Target Weight',
                  controller: _desiredWeightController,
                  keyboardType: TextInputType.number,
                  suffix: 'kg',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your target weight';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight < 30 || weight > 300) {
                      return 'Please enter a valid weight (30-300 kg)';
                    }
                    return null;
                  },
                ),
              ]),
              _buildSection('Health Goals & Lifestyle', [
                _buildDropdown<HealthMode>(
                  label: 'Primary Health Goal',
                  value: _selectedGoal,
                  items: HealthMode.values,
                  itemLabel: (goal) => goal.toSimpleText(),
                  onChanged: (value) => setState(() => _selectedGoal = value!),
                ),
                _buildDropdown<WeeklyPace>(
                  label: 'Preferred Progress Pace',
                  value: _selectedPace,
                  items: WeeklyPace.values,
                  itemLabel: (pace) => pace.toSimpleText(),
                  onChanged: (value) => setState(() => _selectedPace = value!),
                ),
                _buildDropdown<ActivityLevel>(
                  label: 'Activity Level',
                  value: _selectedActivityLevel,
                  items: ActivityLevel.values,
                  itemLabel: (level) => level.toSimpleText(),
                  onChanged: (value) =>
                      setState(() => _selectedActivityLevel = value!),
                ),
              ]),
              _buildSection('Meal Schedule & Preferences', [
                _buildMultiSelect(
                  label: 'Preferred Daily Meals',
                  options: ['Breakfast', 'Lunch', 'Dinner', 'Snacks'],
                  selectedValues: _selectedMeals,
                  onChanged: (values) =>
                      setState(() => _selectedMeals = values),
                ),
                _buildTimePicker(
                  label: 'First Meal Time',
                  selectedTime: _firstMealOfDay,
                  onTimeSelected: (time) =>
                      setState(() => _firstMealOfDay = time),
                ),
                _buildTimePicker(
                  label: 'Second Meal Time',
                  selectedTime: _secondMealOfDay,
                  onTimeSelected: (time) =>
                      setState(() => _secondMealOfDay = time),
                ),
                _buildTimePicker(
                  label: 'Third Meal Time',
                  selectedTime: _thirdMealOfDay,
                  onTimeSelected: (time) =>
                      setState(() => _thirdMealOfDay = time),
                ),
              ]),
              const SizedBox(height: 32),
              SecondaryButton(
                text: 'Save Changes',
                onPressed: _saveUserInfo,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
