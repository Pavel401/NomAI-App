import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:NomAi/app/constants/urls.dart';
import 'package:NomAi/app/models/AI/nutrition_input.dart';
import 'package:NomAi/app/models/AI/nutrition_output.dart';
import 'package:NomAi/app/providers/remoteconfig.dart';

class AiRepository {
  Future<NutritionOutput> getNutritionData(
      NutritionInputQuery inputQuery) async {
    String remoteConfigUrl = RemoteConfigService.getImageProcessingBackendURL();

    // String baseUrl = kDebugMode ? BaseUrl.baseUrl : remoteConfigUrl;
    String baseUrl = remoteConfigUrl + ApiPath.getNutritionData;

    print("🌐 [API Request] Base URL: $baseUrl");

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode(inputQuery.toJsonForMealAIBackend()),
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
