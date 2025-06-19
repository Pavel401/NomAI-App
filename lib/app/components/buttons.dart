import 'package:flutter/material.dart';
import 'package:NomAi/app/constants/colors.dart';

class PrimaryButton extends StatelessWidget {
  final String tile;
  final void Function() onPressed;

  const PrimaryButton({super.key, required this.tile, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: MealAIColors.darkPrimary,
        foregroundColor: MealAIColors.lightPrimary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(tile),
    );
  }
}
