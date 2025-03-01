import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:turfit/app/constants/colors.dart';

enum HeightUnit {
  CM,
  FEET,
}

class HeightPicker extends StatefulWidget {
  final Function(String) onChange;

  const HeightPicker({super.key, required this.onChange});

  @override
  _HeightPickerState createState() => _HeightPickerState();
}

class _HeightPickerState extends State<HeightPicker> {
  HeightUnit _selectedUnit = HeightUnit.CM;
  int _selectedCm = 170;
  int _selectedFeet = 5;
  int _selectedInches = 7;

  void _updateHeight() {
    String height = _selectedUnit == HeightUnit.CM
        ? "$_selectedCm cm"
        : "$_selectedFeet' $_selectedInches\"";
    widget.onChange(height);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Height",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                )),
        // SizedBox(height: 5.h),
        _selectedUnit == HeightUnit.CM
            ? _buildCmPickerWithContainer()
            : _buildFeetInchesPickerWithContainer(),
        SizedBox(height: 5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("CM",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            SizedBox(width: 5.w),
            Switch(
                activeTrackColor: MealAIColors.switchBlackColor,
                inactiveTrackColor: MealAIColors.lightPrimary,
                activeColor: MealAIColors.switchWhiteColor,
                value: _selectedUnit == HeightUnit.CM,
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value ? HeightUnit.CM : HeightUnit.FEET;
                  });
                  _updateHeight();
                }),
            SizedBox(width: 5.w),
            Text("Feet/Inches",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
          ],
        )
      ],
    );
  }

  Widget _buildCmPickerWithContainer() {
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
        _buildCmPicker(),
      ],
    );
  }

  Widget _buildFeetInchesPickerWithContainer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Row for the two highlight containers
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Container(
                  height: 40,
                  width: 20.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  height: 40,
                  width: 20.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Picker widgets
        _buildFeetInchesPicker(),
      ],
    );
  }

  Widget _buildCmPicker() {
    return SizedBox(
      height: 150,
      child: ListWheelScrollView.useDelegate(
        diameterRatio: 1.5,
        itemExtent: 40,
        physics: FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          setState(() {
            _selectedCm = 60 + index;
          });
          _updateHeight();
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) => Center(
            child: Text(
              "${60 + index} cm",
              style: TextStyle(
                fontSize: 18,
                fontWeight: index == _selectedCm - 60
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          childCount: 184,
        ),
      ),
    );
  }

  Widget _buildFeetInchesPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            height: 150,
            child: ListWheelScrollView.useDelegate(
              diameterRatio: 1.5,
              itemExtent: 40,
              physics: FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedFeet = 1 + index;
                });
                _updateHeight();
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) => Center(
                  child: Text(
                    "${1 + index} ft",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: index == _selectedFeet - 1
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                childCount: 9,
              ),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 150,
            child: ListWheelScrollView.useDelegate(
              diameterRatio: 1.5,
              itemExtent: 40,
              physics: FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedInches = index;
                });
                _updateHeight();
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) => Center(
                  child: Text(
                    "$index in",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: index == _selectedInches
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                childCount: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
