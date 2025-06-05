import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/language.dart';
import '../models/quiz.dart';

class LanguageProvider with ChangeNotifier {
  List<Language> translations = [];
  List<Quiz> quizzes = [];
  bool isLoading = false;
  String? _errorMessage;
  String _sourceLanguage = 'en';
  String? _targetLanguage;
  String? _speechTranslation;
  int _requestCount = 0;
  String? _selectedCategory;
  final FlutterTts _flutterTts = FlutterTts();
  Map<String, int> _categoryPerformance = {}; // Track performance per category

  String? get errorMessage => _errorMessage;
  String get sourceLanguage => _sourceLanguage;
  String? get targetLanguage => _targetLanguage;
  String? get speechTranslation => _speechTranslation;
  int get requestCount => _requestCount;
  String? get selectedCategory => _selectedCategory;

  static const String _rapidApiKey = '1f62cf620emsh5709245bb21e4c3p1f9b6fjsnf3a9f0ff2bc6';

  LanguageProvider() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text, String languageCode) async {
    try {
      String ttsLanguage = _mapLanguageCodeToTts(languageCode);
      await _flutterTts.setLanguage(ttsLanguage);
      await _flutterTts.speak(text);
    } catch (e) {
      _errorMessage = 'Failed to play pronunciation for $languageCode: $e. Ensure the language is installed on your device.';
      notifyListeners();
    }
  }

  String _mapLanguageCodeToTts(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'en-US';
      case 'ur':
        return 'ur-PK';
      case 'de':
        return 'de-DE';
      case 'fr':
        return 'fr-FR';
      case 'es':
        return 'es-ES';
      case 'zh-CN':
        return 'zh-CN';
      case 'ja':
        return 'ja-JP';
      case 'ko':
        return 'ko-KR';
      default:
        return 'en-US';
    }
  }

  void setSourceLanguage(String languageCode) {
    if (languageCode != 'en') {
      _errorMessage = 'Source language must be English for predefined phrases. Use speech input for other languages.';
      notifyListeners();
      return;
    }
    _sourceLanguage = languageCode;
    _errorMessage = null;
    notifyListeners();
  }

  void setTargetLanguage(String languageCode) {
    _targetLanguage = languageCode;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  static const Map<String, List<String>> phraseCategories = {
    'Greetings & Introductions': [
      'Hello / Hi',
      'Good morning',
      'Good afternoon',
      'Good evening',
      'Goodbye / Bye',
      'How are you?',
      'I\'m fine, thank you.',
      'What\'s your name?',
      'My name is...',
      'Nice to meet you.',
      'Where are you from?',
      'I\'m from...',
    ],
    'Everyday Basics': [
      'Yes / No',
      'Please',
      'Thank you',
      'You\'re welcome',
      'Excuse me',
      'Sorry',
      'I don\'t understand.',
      'Can you help me?',
      'How much is this?',
      'What time is it?',
    ],
    'Making Plans': [
      'What are you doing?',
      'Do you want to go out?',
      'Let\'s meet at...',
      'When are you free?',
      'See you soon!',
      'I’m running late.',
      'I’ll be there in 10 minutes.',
    ],
    'Shopping & Eating': [
      'I’m just looking, thank you.',
      'I’ll take this one.',
      'Do you have this in a different size?',
      'I’m hungry / thirsty.',
      'Can I see the menu?',
      'I’d like to order...',
      'Could I have the bill, please?',
    ],
    'Asking for Help': [
      'Where is the bathroom?',
      'I’m lost.',
      'Can you speak slowly?',
      'What does this mean?',
      'How do you say ___ in English?',
      'Is there Wi-Fi here?',
    ],
    'Expressing Opinions & Feelings': [
      'In my opinion...',
      'I agree with you.',
      'I don’t think so.',
      'That sounds great.',
      'I’m not sure about that.',
      'It depends.',
      'I’m really excited / worried / confused.',
    ],
    'Professional & Academic Use': [
      'I’d like to schedule a meeting.',
      'Can you send me an email?',
      'Let’s discuss this in detail.',
      'I’ll get back to you.',
      'I appreciate your feedback.',
      'Please let me know if you have any questions.',
    ],
    'Travel & Emergencies': [
      'I need a doctor.',
      'I lost my passport.',
      'Where is the nearest hospital?',
      'Can you call the police?',
      'I missed my flight.',
      'I need to make a reservation.',
    ],
    'Useful Sentence Starters & Fillers': [
      'I think that...',
      'To be honest...',
      'You know...',
      'By the way...',
      'As far as I know...',
      'To sum up...',
      'Let me think...',
    ],
    'Travel & Directions': [
      'Where is the train station?',
      'How far is it from here?',
      'Can you show me on the map?',
      'Turn left / right.',
      'Go straight ahead.',
      'Is it within walking distance?',
    ],
    'Food & Dining': [
      'I’m allergic to...',
      'Is this spicy?',
      'Can you make it quick?',
      'I’d like it to go.',
      'Does this have meat in it?',
      'Can I have some water, please?',
    ],
    'Shopping': [
      'Can I try this on?',
      'Do you accept credit cards?',
      'Is there a discount?',
      'Can you wrap it as a gift?',
      'I need a receipt.',
      'Can I return this?',
    ],
    'Work & Business': [
      'I have a question about...',
      'Can we reschedule?',
      'What’s the deadline?',
      'I need more time.',
      'Let’s set a goal.',
      'Can you explain that again?',
    ],
    'Feelings & Emotions': [
      'I feel happy / sad.',
      'I’m tired.',
      'I’m nervous.',
      'I’m disappointed.',
      'I’m proud of you.',
      'I miss you.',
    ],
    'Emergencies': [
      'Help me!',
      'There’s a fire!',
      'I’m injured.',
      'I need an ambulance.',
      'I’ve been robbed.',
      'It’s an emergency!',
    ],
    'Making Friends': [
      'Do you like to...?',
      'What’s your favorite...?',
      'Let’s hang out sometime.',
      'Can I have your number?',
      'What do you do for fun?',
      'I’d love to get to know you.',
    ],
    'Daily Routine': [
      'I wake up at...',
      'I go to work / school.',
      'I eat breakfast / lunch / dinner.',
      'I take a shower.',
      'I go to bed at...',
      'I usually...',
    ],
    'Talking About the Past/Future': [
      'Yesterday, I...',
      'Last week, I...',
      'When I was a child...',
      'Tomorrow, I will...',
      'Next year, I plan to...',
      'I hope to...',
    ],
  };

  Future<void> fetchTranslations({
    String category = 'Greetings & Introductions',
  }) async {
    if (_targetLanguage == null) {
      _errorMessage = 'Please select a target language first';
      notifyListeners();
      throw Exception(_errorMessage);
    }

    _selectedCategory = category;
    final queries = phraseCategories[category] ?? [];

    isLoading = true;
    _errorMessage = null;
    translations.clear();
    notifyListeners();

    try {
      _requestCount++;
      final url = Uri.parse(
        'https://free-google-translator.p.rapidapi.com/external-api/free-google-translator?from=$_sourceLanguage&to=$_targetLanguage',
      );

      final response = await http.post(
        url,
        headers: {
          'X-RapidAPI-Key': _rapidApiKey,
          'X-RapidAPI-Host': 'free-google-translator.p.rapidapi.com',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'query': queries.join('\n')}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response for batch: $data');
        final translationsList = (data['translation'] as String?)?.split('\n') ?? [];
        for (int i = 0; i < queries.length && i < translationsList.length; i++) {
          final translation = translationsList[i].isNotEmpty ? translationsList[i] : 'Translation unavailable';
          translations.add(
            Language(
              query: queries[i],
              translateTo: '$_sourceLanguage-$_targetLanguage',
              translation: translation,
              status: response.statusCode,
              message: '',
            ),
          );
        }
      } else {
        _errorMessage = 'Failed to load translations: ${response.statusCode} - ${response.body}';
        throw Exception(_errorMessage);
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchQuizzes() async {
    if (translations.isEmpty) {
      _errorMessage = 'No translations available to create quizzes';
      notifyListeners();
      throw Exception(_errorMessage);
    }

    isLoading = true;
    quizzes.clear();
    notifyListeners();

    for (var translation in translations) {
      final correctAnswer = translation.translation;
      final options = [correctAnswer];
      final otherTranslations = translations.where((t) => t.translation != correctAnswer).toList();
      otherTranslations.shuffle();
      options.addAll(otherTranslations.take(3).map((t) => t.translation));

      quizzes.add(
        Quiz(
          question: 'What is "${translation.query}" in $_targetLanguage?',
          options: options,
          correct: correctAnswer,
        ),
      );
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> translateSpeech(String speechText) async {
    if (_targetLanguage == null) {
      _errorMessage = 'Please select a target language first';
      notifyListeners();
      throw Exception(_errorMessage);
    }

    isLoading = true;
    _errorMessage = null;
    _speechTranslation = null;
    notifyListeners();

    _requestCount++;
    try {
      final url = Uri.parse(
        'https://free-google-translator.p.rapidapi.com/external-api/free-google-translator?from=$_sourceLanguage&to=$_targetLanguage&query=${Uri.encodeComponent(speechText)}',
      );

      final response = await http.post(
        url,
        headers: {
          'X-RapidAPI-Key': _rapidApiKey,
          'X-RapidAPI-Host': 'free-google-translator.p.rapidapi.com',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Speech Translation Response: $data');
        _speechTranslation = data['translation'] as String? ?? 'Translation unavailable';
      } else {
        _errorMessage = 'Failed to translate speech: ${response.statusCode} - ${response.body}';
        throw Exception(_errorMessage);
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Personalization: Track quiz performance
  void recordQuizPerformance(String category, bool isCorrect) {
    if (!_categoryPerformance.containsKey(category)) {
      _categoryPerformance[category] = 0;
    }
    _categoryPerformance[category] = _categoryPerformance[category]! + (isCorrect ? 1 : -1);
    notifyListeners();
  }

  // Personalization: Recommend a category to focus on
  String? getPersonalizedFocus() {
    if (_categoryPerformance.isEmpty) return null;
    var worstCategory = _categoryPerformance.entries.reduce((a, b) => a.value < b.value ? a : b);
    if (worstCategory.value < 0) {
      return worstCategory.key; // Recommend the category with the lowest score
    }
    return null; // No recommendation if performance is good
  }
}