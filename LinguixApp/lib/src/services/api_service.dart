import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class APIService {
  static const String apiUrl = 'http://localhost:3000/api/grok3';
  static const String apiKey = 'AIzaSyBERWxAHYLsgMgdvD2TO9S1OTHRIExBImo';
  static Map<String, Map<String, String>> _cache = {}; // Cache by language
  static const Duration _cacheDuration = Duration(minutes: 5);

  Future<Map<String, String>> getQuizSuggestion(String targetLanguage, String weakArea, int userXp) async {
    final cacheKey = '$targetLanguage-$weakArea-$userXp';
    final cached = _cache[cacheKey];
    final now = DateTime.now();

    if (cached != null) {
      final cacheTime = cached['cacheTime'] != null ? DateTime.parse(cached['cacheTime']!) : now;
      if (now.difference(cacheTime) < _cacheDuration) {
        developer.log('Returning cached suggestion for $targetLanguage');
        return {
          'suggestion': cached['suggestion']!,
          'word': cached['word']!,
        };
      }
    }

    try {
      developer.log('Fetching new suggestion for $targetLanguage');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': 'Generate a quiz-focused suggestion for a language learner studying $targetLanguage with $userXp XP, focusing on their weak area: $weakArea. Return JSON: {"suggestion": "learning tip", "word": "word or phrase"}'
                }
              ]
            }
          ],
        }),
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'];
        content = content.replaceAll('```json\n', '').replaceAll('\n```', '').trim();
        developer.log('Cleaned content: $content');

        final parsedContent = jsonDecode(content);
        final result = {
          'suggestion': (parsedContent['suggestion'] ?? 'Practice vocabulary with a quiz!').toString(),
          'word': (parsedContent['word'] ?? 'Hello').toString(),
        };

        _cache[cacheKey] = {...result, 'cacheTime': now.toIso8601String()};
        return result;
      }
      else if (response.statusCode == 429) {
        developer.log('Rate limit exceeded: ${response.body}');
        throw Exception('API rate limit exceeded. Please try again later.');
      } else {
        developer.log('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch suggestion: ${response.body}');
      }
    } catch (e) {
      developer.log('API Service Error: $e');
      return {'suggestion': 'Start with basic greetings in $targetLanguage!', 'word': 'Hello'};
    }
  }
}