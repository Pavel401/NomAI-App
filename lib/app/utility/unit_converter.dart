class UnitConverter {
  static double convertHeightToCm(String height) {
    try {
      height = height.replaceAll(RegExp(r'[^0-9.]'), '').trim();

      if (height.contains("'")) {
        List<String> parts = height.split("'");
        int feet = int.parse(parts[0].trim());
        int inches = parts.length > 1
            ? int.parse(parts[1].replaceAll(RegExp(r'[^0-9]'), '').trim())
            : 0;
        int totalInches = (feet * 12) + inches;
        return double.parse((totalInches * 2.54).toStringAsFixed(2));
      } else {
        return double.parse(height.replaceAll(RegExp(r'[^0-9.]'), '').trim());
      }
    } catch (e) {
      print("Error parsing height: $e");
      return 170.0;
    }
  }

  static double convertWeightToKg(String weight) {
    try {
      weight = weight.replaceAll(RegExp(r'[^0-9.]'), '').trim();

      if (weight.contains("lb")) {
        double lbs = double.parse(weight);
        return double.parse((lbs * 0.453592).toStringAsFixed(2));
      } else {
        return double.parse(weight);
      }
    } catch (e) {
      print("Error parsing weight: $e");
      return 70.0;
    }
  }
}
