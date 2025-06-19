import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/repo/firebase_user_repo.dart';

class AdjustGoalsView extends StatefulWidget {
  UserBasicInfo? userBasicInfo;
  UserModel? userModel;
  UserMacros? userMacros;
  AdjustGoalsView(
      {super.key, this.userMacros, this.userBasicInfo, this.userModel});

  @override
  State<AdjustGoalsView> createState() => _AdjustGoalsViewState();
}

class _AdjustGoalsViewState extends State<AdjustGoalsView> {
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _waterController;
  late TextEditingController _fiberController;

  double _calories = 2000;
  double _protein = 150;
  double _carbs = 250;
  double _fat = 65;
  double _water = 8;
  double _fiber = 25;

  @override
  void initState() {
    super.initState();

    if (widget.userMacros != null) {
      _calories = widget.userMacros!.calories.toDouble().clamp(1000, 4000);
      _protein = widget.userMacros!.protein.toDouble().clamp(50, 300);
      _carbs = widget.userMacros!.carbs.toDouble().clamp(50, 500);
      _fat = widget.userMacros!.fat.toDouble().clamp(20, 150);
      _water = widget.userMacros!.water.toDouble().clamp(4, 16);
      _fiber = widget.userMacros!.fiber.toDouble().clamp(10, 60);
    }

    _caloriesController =
        TextEditingController(text: _calories.toInt().toString());
    _proteinController =
        TextEditingController(text: _protein.toInt().toString());
    _carbsController = TextEditingController(text: _carbs.toInt().toString());
    _fatController = TextEditingController(text: _fat.toInt().toString());
    _waterController = TextEditingController(text: _water.toInt().toString());
    _fiberController = TextEditingController(text: _fiber.toInt().toString());
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _waterController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  Widget _buildMacroCard({
    required String title,
    required String unit,
    required double value,
    required double min,
    required double max,
    required Color color,
    required TextEditingController controller,
    required Function(double) onChanged,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MealAIColors.lightGreyTile,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MealAIColors.blackText,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: MealAIColors.blueGrey,
                      ),
                    ),
                ],
              ),
              Container(
                width: 80,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MealAIColors.blackText,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    suffix: Text(
                      unit,
                      style: TextStyle(
                        fontSize: 12,
                        color: MealAIColors.blueGrey,
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    final newValue = double.tryParse(val) ?? value;
                    if (newValue >= min && newValue <= max) {
                      onChanged(newValue);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              overlayColor: color.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              onChanged: (val) {
                onChanged(val);
                controller.text = val.toInt().toString();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${min.toInt()}$unit',
                style: TextStyle(
                  fontSize: 12,
                  color: MealAIColors.blueGrey,
                ),
              ),
              Text(
                '${max.toInt()}$unit',
                style: TextStyle(
                  fontSize: 12,
                  color: MealAIColors.blueGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MealAIColors.selectedTile,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Daily Macro Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MealAIColors.whiteText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Calories', _calories.toInt().toString(),
                  'kcal', MealAIColors.whiteText),
              _buildSummaryItem('Protein', _protein.toInt().toString(), 'g',
                  MealAIColors.proteinColor),
              _buildSummaryItem('Carbs', _carbs.toInt().toString(), 'g',
                  MealAIColors.carbsColor),
              _buildSummaryItem(
                  'Fat', _fat.toInt().toString(), 'g', MealAIColors.fatColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, String unit, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MealAIColors.whiteText,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: MealAIColors.whiteText.withOpacity(0.7),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: MealAIColors.whiteText.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  void _saveGoals() async {
    final updatedMacros = UserMacros(
      calories: _calories.toInt(),
      protein: _protein.toInt(),
      carbs: _carbs.toInt(),
      fat: _fat.toInt(),
      water: _water.toInt(),
      fiber: _fiber.toInt(),
    );

    UserBasicInfo updatedUserBasicInfo = widget.userBasicInfo!.copyWith(
      userMacros: updatedMacros,
    );

    FirebaseUserRepo firebaseUserRepo = FirebaseUserRepo();

    UserModel updatedUserModel = widget.userModel!.copyWith(
      userInfo: updatedUserBasicInfo,
    );

    await firebaseUserRepo.updateUserData(
      updatedUserModel,
    );

    // TODO: Save to database or state management
    Navigator.pop(context, updatedMacros);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: MealAIColors.blackText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Adjust Goals',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: MealAIColors.blackText,
          ),
        ),
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMacroSummary(),
            const SizedBox(height: 24),
            _buildMacroCard(
              title: 'Calories',
              unit: 'kcal',
              value: _calories,
              min: 1000,
              max: 5000,
              color: MealAIColors.waterColor,
              controller: _caloriesController,
              subtitle: 'Daily energy intake',
              onChanged: (val) => setState(() => _calories = val),
            ),
            _buildMacroCard(
              title: 'Protein',
              unit: 'g',
              value: _protein,
              min: 50,
              max: 300,
              color: MealAIColors.proteinColor,
              controller: _proteinController,
              subtitle: 'Muscle building & repair',
              onChanged: (val) => setState(() => _protein = val),
            ),
            _buildMacroCard(
              title: 'Carbohydrates',
              unit: 'g',
              value: _carbs,
              min: 50,
              max: 500,
              color: MealAIColors.carbsColor,
              controller: _carbsController,
              subtitle: 'Primary energy source',
              onChanged: (val) => setState(() => _carbs = val),
            ),
            _buildMacroCard(
              title: 'Fat',
              unit: 'g',
              value: _fat,
              min: 20,
              max: 150,
              color: MealAIColors.fatColor,
              controller: _fatController,
              subtitle: 'Essential fatty acids',
              onChanged: (val) => setState(() => _fat = val),
            ),
            _buildMacroCard(
              title: 'Water',
              unit: 'cups',
              value: _water,
              min: 4,
              max: 16,
              color: MealAIColors.waterColor,
              controller: _waterController,
              subtitle: 'Daily hydration',
              onChanged: (val) => setState(() => _water = val),
            ),
            _buildMacroCard(
              title: 'Fiber',
              unit: 'g',
              value: _fiber,
              min: 10,
              max: 60,
              color: MealAIColors.carbsColor,
              controller: _fiberController,
              subtitle: 'Digestive health',
              onChanged: (val) => setState(() => _fiber = val),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveGoals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MealAIColors.selectedTile,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Update Goals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MealAIColors.whiteText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
