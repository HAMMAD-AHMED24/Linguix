import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class AIService {
  static const String apiUrl = 'http://localhost:3000/api/grok3';
  static const String apiKey = 'AIzaSyBtHdAz5ivVhfO58pT2VmAWV9A7EEqoJCg'; // Replace with your Gemini API key

  Future<Map<String, String>> getQuizSuggestion(String targetLanguage, String weakArea, int userXp) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'messages': [
            {
              'role': 'user',
              'content': 'Generate a quiz-focused suggestion for a language learner studying $targetLanguage with $userXp XP, focusing on their weak area: $weakArea. Return JSON: {"suggestion": "learning tip", "word": "word or phrase"}'
            }
          ],
          'max_tokens': 100,
        }),
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = jsonDecode(data['choices'][0]['message']['content']); // Decode the JSON string
        return {
          'suggestion': content['suggestion'] ?? 'Practice vocabulary with a quiz!',
          'word': content['word'] ?? 'Hello',
        };
      } else {
        developer.log('API Error: ${response.statusCode} - ${response.body}');
        return {'suggestion': 'Start with basic greetings!', 'word': 'Hello'};
      }
    } catch (e) {
      developer.log('AI Service Error: $e');
      return {'suggestion': 'Start with basic greetings!', 'word': 'Hello'};
    }
  }
}