import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:turfit/app/constants/colors.dart';

enum HeightUnit {
  CM,
  FEET,
}

class HeightPicker extends StatefulWidget {
  final Function(String) onChange;
  final String? initialHeight;

  const HeightPicker({super.key, required this.onChange, this.initialHeight});

  @override
  _HeightPickerState createState() => _HeightPickerState();
}

class _HeightPickerState extends State<HeightPicker> {
  HeightUnit _selectedUnit = HeightUnit.CM;
  int _selectedCm = 170;
  int _selectedFeet = 5;
  int _selectedInches = 7;
  @override
  void initState() {
    super.initState();
    if (widget.initialHeight != null) {
      try {
        if (widget.initialHeight!.contains("cm")) {
          _selectedCm =
              int.parse(widget.initialHeight!.replaceAll(" cm", "").trim());
          _selectedUnit = HeightUnit.CM;
        } else {
          List<String> parts = widget.initialHeight!.split("' ");
          if (parts.length == 2) {
            _selectedFeet = int.parse(parts[0].trim());
            _selectedInches = int.parse(parts[1].replaceAll("\"", "").trim());
          }
          _selectedUnit = HeightUnit.FEET;
        }
      } catch (e) {
        // Fallback to default height
        _selectedCm = 170;
        _selectedFeet = 5;
        _selectedInches = 7;
      }
    }
  }

  void _updateHeight() {
    String height = _selectedUnit == HeightUnit.CM
        ? "$_selectedCm cm"
        : "$_selectedFeet' $_selectedInches\"";
    widget.onChange(height);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "Height",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 4.h),
          _selectedUnit == HeightUnit.CM
              ? _buildCmPickerWithContainer()
              : _buildFeetInchesPickerWithContainer(),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "CM",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(width: 5.w),
              Switch(
                  activeTrackColor: MealAIColors.switchBlackColor,
                  inactiveTrackColor: MealAIColors.lightPrimary,
                  activeColor: MealAIColors.switchWhiteColor,
                  value: _selectedUnit == HeightUnit.FEET,
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value ? HeightUnit.FEET : HeightUnit.CM;
                    });
                    _updateHeight();
                  }),
              SizedBox(width: 5.w),
              Text(
                "Feet/Inches",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          )
        ],
      );
    });
  }

  Widget _buildCmPickerWithContainer() {
    return Center(
      child: Container(
        height: 150,
        width: 60.w,
        child: Stack(
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
            _buildCmPicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeetInchesPickerWithContainer() {
    return Center(
      child: Container(
        height: 150,
        width: 80.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: _buildContainer(_buildFeetPicker()),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Center(
                child: _buildContainer(_buildInchesPicker()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer(Widget child) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 40,
          width: 20.w,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildCmPicker() {
    return SizedBox(
      height: 150,
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: _selectedCm - 60),
        diameterRatio: 1.5,
        itemExtent: 40,
        physics: const FixedExtentScrollPhysics(),
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
                fontSize: 14,
                fontWeight: index == _selectedCm - 60
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          childCount: 184,
        ),
      ),
    );
  }

  Widget _buildFeetPicker() {
    return SizedBox(
      height: 150,
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: _selectedFeet - 1),
        itemExtent: 40,
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
                fontSize: 14,
                fontWeight: index == _selectedCm - 60
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          childCount: 9,
        ),
      ),
    );
  }

  Widget _buildInchesPicker() {
    return SizedBox(
      height: 150,
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: _selectedInches),
        itemExtent: 40,
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
                fontSize: 14,
                fontWeight: index == _selectedCm - 60
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          childCount: 12,
        ),
      ),
    );
  }
}
