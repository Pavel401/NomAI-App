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

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Widget? loadingWidget;
  final bool hasElevation;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.borderRadius = 16,
    this.padding,
    this.textStyle,
    this.loadingWidget,
    this.hasElevation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: hasElevation
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? MealAIColors.black,
          foregroundColor: foregroundColor ?? Colors.white,
          disabledBackgroundColor: disabledBackgroundColor ?? MealAIColors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          padding: padding ?? EdgeInsets.zero,
        ),
        child: isLoading
            ? loadingWidget ??
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: foregroundColor ?? Colors.white,
                    strokeWidth: 2,
                  ),
                )
            : Text(
                text,
                style: textStyle ??
                    TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
              ),
      ),
    );
  }
}
