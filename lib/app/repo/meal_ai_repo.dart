import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:turfit/app/constants/urls.dart';

import '../models/AI/nutrition_input.dart';
import '../models/AI/nutrition_output.dart';

class AiRepository {
  Future<NutritionOutput> getNutritionData(
      NutritionInputQuery inputQuery) async {
    final response = await http.post(
      Uri.parse(BaseUrl.baseUrl + ApiPath.getNutritionData),
      body: jsonEncode(inputQuery.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return NutritionOutput.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to fetch data");
    }
  }
}
