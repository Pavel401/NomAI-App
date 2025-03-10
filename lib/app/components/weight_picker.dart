import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:turfit/app/constants/colors.dart';

enum WeightUnit {
  KG,
  LB,
}

class WeightPicker extends StatefulWidget {
  final Function(String) onChange;
  final String? initialWeight;

  const WeightPicker({super.key, required this.onChange, this.initialWeight});

  @override
  _WeightPickerState createState() => _WeightPickerState();
}

class _WeightPickerState extends State<WeightPicker> {
  WeightUnit _selectedUnit = WeightUnit.KG;
  int _selectedKg = 70;
  int _selectedLbs = 155;
  @override
  void initState() {
    super.initState();
    if (widget.initialWeight != null) {
      try {
        if (widget.initialWeight!.contains("kg")) {
          _selectedKg =
              int.parse(widget.initialWeight!.replaceAll(" kg", "").trim());
          _selectedUnit = WeightUnit.KG;
        } else if (widget.initialWeight!.contains("lb")) {
          _selectedLbs =
              int.parse(widget.initialWeight!.replaceAll(" lb", "").trim());
          _selectedUnit = WeightUnit.LB;
        }
      } catch (e) {
        // Fallback to default values
        _selectedKg = 70;
        _selectedLbs = 155;
      }
    }
  }

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
                value: _selectedUnit == WeightUnit.LB,
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value ? WeightUnit.LB : WeightUnit.KG;
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
        Container(
          height: 40,
          width: 25.w,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        _buildKgPicker(),
      ],
    );
  }

  Widget _buildLbsPickerWithContainer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 40,
          width: 25.w,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        _buildLbsPicker(),
      ],
    );
  }

  Widget _buildKgPicker() {
    return SizedBox(
      height: 150,
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: _selectedKg - 30),
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
            child: Text("${30 + index} kg"),
          ),
          childCount: 271,
        ),
      ),
    );
  }

  Widget _buildLbsPicker() {
    return SizedBox(
      height: 150,
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: _selectedLbs - 66),
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
            child: Text("${66 + index} lb"),
          ),
          childCount: 596,
        ),
      ),
    );
  }
}
