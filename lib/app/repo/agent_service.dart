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
    print('Loading chat history for user: $userId');

    try {
      final uri = Uri.parse(
          '$_baseUrl/chat/messages?user_id=${Uri.encodeComponent(userId)}');
      print('Making GET request to: $uri');

      final stopwatch = Stopwatch()..start();

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
      );

      stopwatch.stop();
      print('Request completed in ${stopwatch.elapsedMilliseconds}ms');
      print('Response status: ${response.statusCode}');
      print('Response body length: ${response.body.length} characters');

      if (response.statusCode == 200) {
        final text = response.body.trim();
        if (text.isEmpty) {
          print('Empty response body - returning empty list');
          return [];
        }

        print('Parsing response body into messages');
        // Follow web implementation: split by newlines and filter empty lines
        final lines = text
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();
        print('Found ${lines.length} message lines to parse');

        final messages = <AgentResponse>[];
        int parseErrors = 0;

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
            } else {
              print(
                  'Unexpected message format at line ${i + 1}: ${jsonData.runtimeType}');
            }
          } catch (parseError) {
            parseErrors++;
            print('Failed to parse message line ${i + 1}: $parseError');
            print('Problematic line: ${lines[i]}');
          }
        }

        if (parseErrors > 0) {
          print(
              '$parseErrors message(s) failed to parse out of ${lines.length}');
        }

        // Sort messages by timestamp to ensure correct order (like web implementation)
        messages.sort((a, b) {
          if (a.timestamp == null && b.timestamp == null) return 0;
          if (a.timestamp == null) return -1;
          if (b.timestamp == null) return 1;
          return a.timestamp!.compareTo(b.timestamp!);
        });

        print(
            'Successfully loaded ${messages.length} messages for user: $userId');
        return messages;
      } else {
        print('HTTP error: ${response.statusCode} - ${response.reasonPhrase}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load chat history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading chat history for user $userId: $e');
      return []; // Return empty list instead of throwing
    }
  }

  Stream<AgentResponse> sendMessage(
      String message, String userId, UserModel user,
      {String? foodImage}) async* {
    print('Sending message from user: $userId');
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

      print('DEBUG: Prepared JSON payload: $jsonPayload');

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

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final lines = response.body
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty);

        for (final line in lines) {
          try {
            final messageData = json.decode(line);
            print('DEBUG: Raw message data: $messageData');
            print('DEBUG: Message data type: ${messageData.runtimeType}');

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

              // Log different types of messages for debugging
              if (messageData.containsKey('is_tool_call') &&
                  messageData['is_tool_call'] == true) {
                print('DEBUG: Tool call message detected');
              } else if (messageData.containsKey('is_tool_result') &&
                  messageData['is_tool_result'] == true) {
                print('DEBUG: Tool result message detected');
              } else if (messageData.containsKey('is_partial') &&
                  messageData['is_partial'] == true) {
                print('DEBUG: Partial message detected');
              } else if (messageData.containsKey('is_final') &&
                  messageData['is_final'] == true) {
                print('DEBUG: Final message detected');
              }

              yield agentResponse;
            } else {
              print('Unexpected message format: ${messageData.runtimeType}');
            }
          } catch (e) {
            print('Failed to parse message: $e');
            print('Raw line: $line');
          }
        }
      } else {
        print('HTTP error: ${response.statusCode} - ${response.reasonPhrase}');
        yield AgentResponse(
          role: 'model',
          timestamp: DateTime.now(),
          content:
              'Sorry, I encountered an error while processing your request. Please try again.',
          isFinal: true,
        );
      }
    } catch (e) {
      print('Error sending message: $e');
      yield AgentResponse(
        role: 'model',
        timestamp: DateTime.now(),
        content:
            'Sorry, I encountered an error while processing your request. Please try again.',
        isFinal: true,
      );
    }
  }

  static Future<bool> healthCheck() async {
    print('Performing health check...');
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      stopwatch.stop();

      if (response.statusCode == 200) {
        print('Health check passed in ${stopwatch.elapsedMilliseconds}ms');
        return true;
      } else {
        print('Health check failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Health check error: $e');
      return false;
    }
  }

  static void logServiceInfo() {
    print('AgentService Configuration:');
    print('Base URL: $_baseUrl');
    print('Current Time: ${DateTime.now().toIso8601String()}');
  }
}
