import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:turfit/app/constants/colors.dart';

enum WeightUnit {
  KG,
  LB,
}

class WeightPicker extends StatefulWidget {
  final Function(String) onChange;

  const WeightPicker({super.key, required this.onChange});

  @override
  _WeightPickerState createState() => _WeightPickerState();
}

class _WeightPickerState extends State<WeightPicker> {
  WeightUnit _selectedUnit = WeightUnit.KG;
  int _selectedKg = 70;
  int _selectedLbs = 155;

  void _updateWeight() {
    String weight =
        _selectedUnit == WeightUnit.KG ? "$_selectedKg kg" : "$_selectedLbs lb";
    widget.onChange(weight);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Weight",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                )),
        SizedBox(height: 5.h),
        _selectedUnit == WeightUnit.KG
            ? _buildKgPickerWithContainer()
            : _buildLbsPickerWithContainer(),
        SizedBox(height: 5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("KG",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            SizedBox(width: 5.w),
            Switch(
                activeTrackColor: MealAIColors.switchBlackColor,
                inactiveTrackColor: MealAIColors.lightPrimary,
                activeColor: MealAIColors.switchWhiteColor,
                value: _selectedUnit == WeightUnit.KG,
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value ? WeightUnit.KG : WeightUnit.LB;
                  });
                  _updateWeight();
                }),
            SizedBox(width: 5.w),
            Text("Pounds",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
          ],
        )
      ],
    );
  }

  Widget _buildKgPickerWithContainer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Grey container highlighting the current selection
        Container(
          height: 40,
          width: 25.w,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // Picker widget
        _buildKgPicker(),
      ],
    );
  }

  Widget _buildLbsPickerWithContainer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Grey container highlighting the current selection
        Container(
          height: 40,
          width: 25.w,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // Picker widget
        _buildLbsPicker(),
      ],
    );
  }

  Widget _buildKgPicker() {
    return SizedBox(
      height: 150,
      child: ListWheelScrollView.useDelegate(
        diameterRatio: 1.5,
        itemExtent: 40,
        physics: FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          setState(() {
            _selectedKg = 30 + index;
          });
          _updateWeight();
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) => Center(
            child: Text(
              "${30 + index} kg",
              style: TextStyle(
                fontSize: 18,
                fontWeight: index == _selectedKg - 30
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          // Weight range from 30kg to 300kg
          childCount: 271,
        ),
      ),
    );
  }

  Widget _buildLbsPicker() {
    return SizedBox(
      height: 150,
      child: ListWheelScrollView.useDelegate(
        diameterRatio: 1.5,
        itemExtent: 40,
        physics: FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          setState(() {
            _selectedLbs = 66 + index;
          });
          _updateWeight();
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) => Center(
            child: Text(
              "${66 + index} lb",
              style: TextStyle(
                fontSize: 18,
                fontWeight: index == _selectedLbs - 66
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          // Weight range from 66lb to 661lb (equivalent to ~30kg-300kg)
          childCount: 596,
        ),
      ),
    );
  }
}
