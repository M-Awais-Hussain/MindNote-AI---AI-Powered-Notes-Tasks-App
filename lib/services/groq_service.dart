import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  static final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  static final String _model = dotenv.env['GROQ_MODEL'] ?? 'mixtral-8x7b-32768';
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  Future<String> getChatCompletion(List<Map<String, String>> messages) async {
    if (_apiKey.isEmpty) {
      throw Exception('Groq API Key not found in .env file');
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          'Groq API Error: ${error['error']['message'] ?? response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to get response from Groq: $e');
    }
  }

  // Specialized helper for simple prompts
  Future<String> quickPrompt(String prompt) async {
    return getChatCompletion([
      {'role': 'user', 'content': prompt},
    ]);
  }
}
