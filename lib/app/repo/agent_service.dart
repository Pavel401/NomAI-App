import 'dart:convert';
import 'dart:async';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:http/http.dart' as http;
import 'package:NomAi/app/models/Agent/agent_response.dart';
import 'package:NomAi/app/models/Agent/chat_message_request.dart';

class AgentService {
  static const String _baseUrl =
      'https://nomai-production.up.railway.app'; // Adjust to your API URL

  Future<List<AgentResponse>> getChatHistory(String userId) async {
    try {
      final uri = Uri.parse(
          '$_baseUrl/chat/messages?user_id=${Uri.encodeComponent(userId)}');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final text = response.body.trim();
        if (text.isEmpty) {
          return [];
        }

        // Follow web implementation: split by newlines and filter empty lines
        final lines = text
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

        final messages = <AgentResponse>[];

        for (int i = 0; i < lines.length; i++) {
          try {
            final jsonData = json.decode(lines[i]);

            // Handle both single messages and arrays (like web implementation)
            if (jsonData is List) {
              for (final item in jsonData) {
                if (item is Map<String, dynamic>) {
                  final message = AgentResponse.fromJson(item);
                  messages.add(message);
                }
              }
            } else if (jsonData is Map<String, dynamic>) {
              final message = AgentResponse.fromJson(jsonData);
              messages.add(message);
            }
          } catch (parseError) {
            // Silently continue on parse errors
            continue;
          }
        }

        // Sort messages by timestamp to ensure correct order (like web implementation)
        messages.sort((a, b) {
          if (a.timestamp == null && b.timestamp == null) return 0;
          if (a.timestamp == null) return -1;
          if (b.timestamp == null) return 1;
          return a.timestamp!.compareTo(b.timestamp!);
        });

        return messages;
      } else {
        throw Exception('Failed to load chat history: ${response.statusCode}');
      }
    } catch (e) {
      return []; // Return empty list instead of throwing
    }
  }

  Stream<AgentResponse> sendMessage(
      String message, String userId, UserModel user,
      {String? foodImage}) async* {
    try {
      final uri = Uri.parse('$_baseUrl/chat/messages');

      // Create structured request using ChatMessageRequest model
      final chatRequest = ChatMessageRequest(
        prompt: message,
        userId: userId,
        localTime: DateTime.now().toIso8601String(),
        dietaryPreferences: user.userInfo?.selectedDiet != null
            ? [user.userInfo!.selectedDiet]
            : null,
        allergies: user.userInfo?.selectedAllergies,
        selectedGoals: user.userInfo?.selectedGoal != null
            ? [user.userInfo!.selectedGoal.toSimpleText()]
            : null,
        foodImage: foodImage,
      );

      final jsonPayload = chatRequest.toJson();

      // Remove null and empty values
      jsonPayload.removeWhere((key, value) =>
          value == null ||
          (value is String && value.isEmpty) ||
          (value is List && value.isEmpty));

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(jsonPayload),
      );

      if (response.statusCode == 200) {
        final lines = response.body
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty);

        for (final line in lines) {
          try {
            final messageData = json.decode(line);

            // Handle both arrays and objects (like web implementation)
            if (messageData is List) {
              for (final item in messageData) {
                if (item is Map<String, dynamic>) {
                  yield AgentResponse.fromJson(item);
                }
              }
            } else if (messageData is Map<String, dynamic>) {
              // Handle special message types like web implementation
              final agentResponse = AgentResponse.fromJson(messageData);
              yield agentResponse;
            }
          } catch (e) {
            // Silently continue on parse errors
            continue;
          }
        }
      } else {
        yield AgentResponse(
          role: AgentRole.model,
          timestamp: DateTime.now(),
          content:
              'Sorry, I encountered an error while processing your request. Please try again.',
          isFinal: true,
        );
      }
    } catch (e) {
      yield AgentResponse(
        role: AgentRole.model,
        timestamp: DateTime.now(),
        content:
            'Sorry, I encountered an error while processing your request. Please try again.',
        isFinal: true,
      );
    }
  }

  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
