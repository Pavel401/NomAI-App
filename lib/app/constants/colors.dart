import 'package:flutter/material.dart';

class MealAIColors {
  static const Color darkPrimary = Color(0xFF000000); // #000000
  static const Color lightPrimaryVariant = Color(0xFFB0BEC5); // #B0BEC5
  static const Color darkPrimaryVariant = Color(0xFF383838); // #383838
  static const Color darkSecondary = Color(0xFF434343); // #434343
  static const Color darkSecondaryVariant = Color(0xFF757575); // #757575
  static const Color darkSuccess = Color(0xFF00C853); // #00C853
  static const Color darkSuccessVariant = Color(0xFF66BB6A); // #66BB6A
  static const Color darkInfo = Color(0xFF2979FF); // #2979FF
  static const Color darkInfoVariant = Color(0xFF80D8FF); // #80D8FF
  static const Color darkWarning = Color(0xFFFFB300); // #FFB300
  static const Color darkWarningVariant = Color(0xFFFFCC80); // #FFCC80
  static const Color darkError = Color(0xFFD32F2F); // #D32F2F
  static const Color darkErrorVariant = Color(0xFFEF9A9A); // #EF9A9A
  static const Color darkSurface = Color(0xFF121212); // #121212
  static const Color darkBackground = Color(0xFF1E1E1E); // #1E1E1E
  static const Color darkOnPrimary = Color(0xFFFFFFFF); // #FFFFFF
  static const Color darkOnSecondary = Color(0xFFFFFFFF); // #FFFFFF
  static const Color darkOnSuccess = Color(0xFF000000); // #000000
  static const Color darkOnInfo = Color(0xFF000000); // #000000
  static const Color darkOnWarning = Color(0xFF000000); // #000000
  static const Color darkOnError = Color(0xFFFFFFFF); // #FFFFFF
  static const Color darkOnSurface = Color(0xFFFFFFFF); // #FFFFFF
  static const Color darkOnBackground = Color(0xFFFFFFFF); // #FFFFFF

  static const Color lightPrimary = Color(0xFFFFFFFF); // #FFFFFF
  static const Color lightSecondary = Color(0xFF000000); // #000000
  static const Color lightSecondaryVariant = Color(0xFF757575); // #757575
  static const Color lightSuccess = Color(0xFF4CAF50); // #4CAF50
  static const Color lightSuccessVariant = Color(0xFF81C784); // #81C784
  static const Color lightInfo = Color(0xFF0288D1); // #0288D1
  static const Color lightInfoVariant = Color(0xFF40C4FF); // #40C4FF
  static const Color lightWarning = Color(0xFFFFB300); // #FFB300
  static const Color lightWarningVariant = Color(0xFFFFCC80); // #FFCC80
  static const Color lightError = Color(0xFFD32F2F); // #D32F2F
  static const Color lightErrorVariant = Color(0xFFEF9A9A); // #EF9A9A
  static const Color lightSurface = Color(0xFFFFFFFF); // #FFFFFF
  static const Color lightBackground = Color(0xFFF5F5F5); // #F5F5F5
  static const Color lightOnPrimary = Color(0xFF000000); // #000000
  static const Color lightOnSecondary = Color(0xFFFFFFFF); // #FFFFFF
  static const Color lightOnSuccess = Color(0xFFFFFFFF); // #FFFFFF
  static const Color lightOnInfo = Color(0xFFFFFFFF); // #FFFFFF
  static const Color lightOnWarning = Color(0xFF000000); // #000000
  static const Color lightOnError = Color(0xFFFFFFFF); // #FFFFFF
  static const Color lightOnSurface = Color(0xFF000000); // #000000
  static const Color lightOnBackground = Color(0xFF000000); // #000000


  static Color lightGreyTile = "#F9F8FD".toColor();

  static Color grey = Colors.grey;
  static const Color selectedTile = Color(0xFF212121);
  static const Color switchWhiteColor = Color(0xFFFFFFFF);
  static const Color switchBlackColor = Color(0xFF000000);
  static const Color black = Color(0xFF000000);

  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color blackText = Color(0xFF000000);
  static const Color red = Color(0xFFFF0000);

  static Color blueGrey = "#514f62".toColor();

  static const Color stepperColor = Color(0xFFE0E0E0);

  static const Color greyLight = Color.fromRGBO(235, 235, 235, 1);

  static Color gaugeColor = Colors.grey.withOpacity(0.2);
  static Color proteinColor = "#E91E63".toColor(); // Pink for protein/strength
  static Color carbsColor = "#558B2F".toColor();
  static Color fatColor = Colors.blue;
  static Color waterColor =
      "#0288D1".toColor(); // Richer blue for water/hydration
}

extension HexColorExtension on String {
  Color toColor() {
    String hex = replaceAll("#", "").toUpperCase();
    if (hex.length == 6) {
      hex = "FF$hex"; // Add full opacity if not specified
    }
    return Color(int.parse("0x$hex"));
  }
}
