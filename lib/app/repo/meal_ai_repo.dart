import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:NomAi/app/constants/urls.dart';
import 'package:NomAi/app/models/AI/nutrition_input.dart';
import 'package:NomAi/app/models/AI/nutrition_output.dart';
import 'package:NomAi/app/providers/remoteconfig.dart';

class AiRepository {
  Future<NutritionOutput> getNutritionData(
      NutritionInputQuery inputQuery) async {
    String remoteConfigUrl = RemoteConfigService.getImageProcessingBackendURL();

    String baseUrl = remoteConfigUrl + ApiPath.getNutritionData;

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode(inputQuery.toJsonForMealAIBackend()),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return NutritionOutput.fromJson(json.decode(response.body));
      } else {
        return NutritionOutput(
          status: response.statusCode,
          message:
              "API request failed with status ${response.statusCode}: ${response.body}",
          response: null,
        );
      }
    } catch (e) {
      return NutritionOutput(
        status: 500,
        message: "Network error: ${e.toString()}",
        response: null,
      );
    }
  }
}
