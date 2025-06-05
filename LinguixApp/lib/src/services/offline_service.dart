import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OfflineService {
  late Box<Map<String, dynamic>> _lessonsBox;

  OfflineService() {
    _initHive();
  }

  Future<void> _initHive() async {
    _lessonsBox = await Hive.openBox<Map<String, dynamic>>('lessons');
  }

  Future<void> downloadLesson(String language, String lessonId) async {
    final response = await http.get(Uri.parse('https://your-api.com/lessons/$language/$lessonId'));
    if (response.statusCode == 200) {
      final lessonData = jsonDecode(response.body);
      await _lessonsBox.put('$language-$lessonId', lessonData);
    }
  }

  Future<Map<String, dynamic>?> getLesson(String language, String lessonId) async {
    return _lessonsBox.get('$language-$lessonId');
  }
}