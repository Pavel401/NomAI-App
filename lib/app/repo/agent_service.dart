import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:NomAi/app/models/Agent/agent_response.dart';

class AgentService {
  static const String _baseUrl =
      'https://nomai-production.up.railway.app'; // Adjust to your API URL

  Future<List<AgentResponse>> getChatHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/chat/messages?user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final text = response.body.trim();
        if (text.isEmpty) return [];

        return text
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => AgentResponse.fromJson(json.decode(line)))
            .toList();
      } else {
        throw Exception('Failed to load chat history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading chat history: $e');
      return []; // Return empty list instead of throwing
    }
  }

  Stream<AgentResponse> sendMessage(String message, String userId) async* {
    try {
      final formData = <String, String>{
        'prompt': message,
        'user_id': userId,
      };

      final request =
          http.MultipartRequest('POST', Uri.parse('$_baseUrl/chat/messages'));
      formData.forEach((key, value) {
        request.fields[key] = value;
      });
      request.headers['Accept'] = 'text/plain';

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        await for (final chunk
            in streamedResponse.stream.transform(utf8.decoder)) {
          final lines =
              chunk.split('\n').where((line) => line.trim().isNotEmpty);

          for (final line in lines) {
            try {
              final messageData = json.decode(line);
              yield AgentResponse.fromJson(messageData);
            } catch (parseError) {
              print('Error parsing message: $parseError');
            }
          }
        }
      } else {
        throw Exception('HTTP error: ${streamedResponse.statusCode}');
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
}
