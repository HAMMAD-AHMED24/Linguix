import 'dart:convert';
import 'package:http/http.dart' as http;

class MongoService {
  static const String _baseUrl = 'http://localhost:3000/api';

  Future<void> saveQuizProgress(String userId, String language, int score, int total, DateTime date) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/saveQuizProgress'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'language': language,
          'score': score,
          'total': total,
          'date': date.toIso8601String(),
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to save quiz progress: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to save quiz progress: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getQuizProgress(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/getQuizProgress/$userId'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch quiz progress: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch quiz progress: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAssignments() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/getAssignments'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch assignments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch assignments: $e');
    }
  }

  Future<void> insertSampleAssignments() async {
    try {
      final response = await http.post(Uri.parse('$_baseUrl/insertSampleAssignments'));
      if (response.statusCode != 200) {
        throw Exception('Failed to insert sample assignments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to insert sample assignments: $e');
    }
  }
}