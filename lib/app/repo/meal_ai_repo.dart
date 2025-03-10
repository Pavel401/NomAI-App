import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:turfit/app/constants/urls.dart';
import 'package:turfit/app/models/AI/nutrition_input.dart';
import 'package:turfit/app/models/AI/nutrition_output.dart';

class AiRepository {
  Future<NutritionOutput> getNutritionData(
      NutritionInputQuery inputQuery) async {
    try {
      final response = await http.post(
        Uri.parse(BaseUrl.baseUrl + ApiPath.getNutritionData),
        body: jsonEncode(inputQuery.toJson()),
        headers: {"Content-Type": "application/json"},
      );

      // ✅ Log the full response body (even if it's an error)
      print("📡 [API Response] Status Code: ${response.statusCode}");
      print("📜 [API Response] Body: ${response.body}");

      if (response.statusCode == 200) {
        return NutritionOutput.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            "❌ Failed to fetch data - Status: ${response.statusCode}\nBody: ${response.body}");
      }
    } catch (e) {
      print("🔥 [API Error] $e");
      throw Exception("❌ Something went wrong: $e");
    }
  }
}
