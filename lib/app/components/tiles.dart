import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';

class PrimaryTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const PrimaryTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(bottom: 2.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? MealAIColors.selectedTile
              : MealAIColors.lightGreyTile,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? MealAIColors.whiteText
                          : MealAIColors.blackText,
                    ),
                maxLines: 2, // Allow the text to span up to two lines
                overflow:
                    TextOverflow.ellipsis, // Add ellipsis if text overflows
                textAlign: TextAlign.center, // Center the text
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondaryTile extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const SecondaryTile({
    super.key,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(bottom: 2.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? MealAIColors.selectedTile
              : MealAIColors.lightGreyTile,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? MealAIColors.whiteText
                              : MealAIColors.blackText,
                        ),
                  ),
                  SizedBox(height: 1.w),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: isSelected
                              ? MealAIColors.whiteText.withOpacity(0.8)
                              : MealAIColors.blackText.withOpacity(0.7),
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrimaryIconTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const PrimaryIconTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(bottom: 2.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color:
              isSelected ? MealAIColors.blackText : MealAIColors.lightGreyTile,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor:
                  isSelected ? MealAIColors.whiteText : MealAIColors.blackText,
              child: Icon(
                icon,
                color: isSelected
                    ? MealAIColors.blackText
                    : MealAIColors.whiteText,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? MealAIColors.whiteText
                        : MealAIColors.blackText,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class MealTimePicker extends StatefulWidget {
  final String title;
  final bool isSelected;
  final IconData icon;
  final ValueChanged<TimeOfDay?> onTimeChanged; // Callback to return time

  const MealTimePicker({
    super.key,
    required this.title,
    required this.isSelected,
    required this.icon,
    required this.onTimeChanged, // Required parameter for time change callback
  });

  @override
  _MealTimePickerState createState() => _MealTimePickerState();
}

class _MealTimePickerState extends State<MealTimePicker> {
  TimeOfDay? selectedTime;

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: MealAIColors.selectedTile, // Custom primary color
              onPrimary: MealAIColors.whiteText, // Text color on primary
              surface: MealAIColors.lightGreyTile, // Background color
              onSurface: MealAIColors.blackText, // Text color on surface
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
      widget.onTimeChanged(picked); // Notify parent of time change
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickTime(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(bottom: 8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? MealAIColors.blackText
              : MealAIColors.lightGreyTile,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: widget.isSelected
                      ? MealAIColors.whiteText
                      : MealAIColors.blackText,
                  child: Icon(
                    widget.icon,
                    color: widget.isSelected
                        ? MealAIColors.blackText
                        : MealAIColors.whiteText,
                  ),
                ),
                SizedBox(width: 16.0),
                Text(
                  selectedTime != null
                      ? selectedTime!.format(context)
                      : widget.title,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.isSelected
                            ? MealAIColors.whiteText
                            : MealAIColors.blackText,
                      ),
                ),
              ],
            ),
            Icon(
              selectedTime != null ? Icons.edit : Icons.add,
              color: widget.isSelected
                  ? MealAIColors.whiteText
                  : MealAIColors.blackText,
            ),
          ],
        ),
      ),
    );
  }
}
