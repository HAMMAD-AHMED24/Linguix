import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/language.dart';
import '../models/quiz.dart';
import 'dart:math';

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
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  Map<String, int> _categoryPerformance = {};
  Map<String, int> _stageProgress = {};
  int _currentStage = 0;
  List<String> get categories => phraseCategories.keys.toList();

  String? get errorMessage => _errorMessage;
  String get sourceLanguage => _sourceLanguage;
  String? get targetLanguage => _targetLanguage;
  String? get speechTranslation => _speechTranslation;
  int get requestCount => _requestCount;
  String? get selectedCategory => _selectedCategory;
  int get currentStage => _currentStage;
  Map<String, int> get stageProgress => _stageProgress;
  static const List<String> stages = ['Beginner', 'Intermediate', 'Advanced'];

  static const String _rapidApiKey = '1f62cf620emsh5709245bb21e4c3p1f9b6fjsnf3a9f0ff2bc6';
  static const String _grokApiUrl = 'http://localhost:3000/api/grok3'; // Replace with actual xAI endpoint
  static const String _grokApiKey = 'xai-RpEgpahvj6Iv07YAm0fncwTll82tdWPhq8t2vgc824FWwdMF3kKjcyzWiRyjTvHeSNXtQQ6L402l1pS1'; // Obtain from https://x.ai/api

  LanguageProvider() {
    _initTts();
    _initSpeech();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _initSpeech() async {
    await _speechToText.initialize();
  }

  Future<void> speak(String text, String languageCode) async {
    try {
      String ttsLanguage = _mapLanguageCodeToTts(languageCode);
      await _flutterTts.setLanguage(ttsLanguage);
      await _flutterTts.speak(text);
    } catch (e) {
      _errorMessage = 'Failed to play pronunciation for $languageCode: $e';
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
      _errorMessage = 'Source language must be English for predefined phrases';
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
    // Same as provided, unchanged for brevity
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

  Future<void> fetchTranslations({required String category}) async {
    if (_targetLanguage == null) {
      _errorMessage = 'Please select a target language first';
      notifyListeners();
      throw Exception(_errorMessage);
    }

    _selectedCategory = category;
    final queries = phraseCategories[category] ?? [];

    if (queries.isEmpty) {
      _errorMessage = 'No phrases available for category: $category';
      notifyListeners();
      throw Exception(_errorMessage);
    }

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
              category: category,
            ),
          );
        }
      } else {
        _errorMessage = 'Failed to load translations: ${response.statusCode}';
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
      options.shuffle();

      quizzes.add(
        Quiz(
          question: 'What is "${translation.query}" in $_targetLanguage?',
          options: options,
          correct: correctAnswer,
          category: translation.category ?? _selectedCategory ?? 'Unknown',
        ),
      );
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchQuizForWord(String language, String word) async {
    if (language != _targetLanguage) {
      _errorMessage = 'Target language mismatch';
      notifyListeners();
      throw Exception(_errorMessage);
    }

    isLoading = true;
    _errorMessage = null;
    translations.clear();
    quizzes.clear();
    notifyListeners();

    try {
      _requestCount++;
      final response = await http.post(
        Uri.parse(_grokApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_grokApiKey',
        },
        body: jsonEncode({
          'prompt': 'Generate a translation pair for the word "$word" from English to $language, and 3 incorrect translations as distractors. Return JSON: {"query": "English word", "translation": "Translated word", "distractors": ["wrong1", "wrong2", "wrong3"]}',
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final query = data['choices'][0]['text']['query'] ?? word;
        final translation = data['choices'][0]['text']['translation'] ?? word;
        final distractors = List<String>.from(data['choices'][0]['text']['distractors'] ?? []);

        translations.add(
          Language(
            query: query,
            translateTo: 'en-$language',
            translation: translation,
            status: 200,
            message: '',
            category: _selectedCategory ?? 'Custom',
          ),
        );

        quizzes.add(
          Quiz(
            question: 'What is "$query" in $language?',
            options: [translation, ...distractors.take(3)],
            correct: translation,
            category: _selectedCategory ?? 'Custom',
          ),
        );
      } else {
        _errorMessage = 'Failed to fetch quiz for word: ${response.statusCode}';
        translations.add(
          Language(
            query: word,
            translateTo: 'en-$language',
            translation: word,
            status: response.statusCode,
            message: 'API error',
            category: 'Custom',
          ),
        );
        quizzes.add(
          Quiz(
            question: 'What is "$word" in $language?',
            options: [word, 'Option 1', 'Option 2', 'Option 3'],
            correct: word,
            category: 'Custom',
          ),
        );
      }
    } catch (e) {
      _errorMessage = 'Error fetching quiz for word: $e';
      translations.add(
        Language(
          query: word,
          translateTo: 'en-$language',
          translation: word,
          status: 500,
          message: e.toString(),
          category: 'Custom',
        ),
      );
      quizzes.add(
        Quiz(
          question: 'What is "$word" in $language?',
          options: [word, 'Option 1', 'Option 2', 'Option 3'],
          correct: word,
          category: 'Custom',
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
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

  Future<String?> recognizeSpeech() async {
    print('Starting speech recognition...');
    if (!_speechToText.isAvailable) {
      _errorMessage = 'Speech recognition not available on this device';
      print(_errorMessage);
      notifyListeners();
      return null;
    }

    // Log available locales (returns List<LocaleName>)
    List<stt.LocaleName> locales = await _speechToText.locales(); // Await the future
    print('Available locales: ${locales.map((l) => l.localeId).toList()}');
    print('Using locale: $_targetLanguage');

    // Fallback to en-US if the target language isn’t supported
    String localeToUse = _targetLanguage ?? 'en-US';
    if (!locales.any((locale) => locale.localeId == localeToUse)) {
      print('Locale $localeToUse not supported, falling back to en-US');
      localeToUse = 'en-US';
    }

    bool isListening = await _speechToText.listen(
      onResult: (result) {
        print('Speech result: ${result.recognizedWords}, final: ${result.finalResult}');
        if (result.finalResult) {
          _speechToText.stop();
        }
      },
      localeId: localeToUse,
      listenFor: const Duration(seconds: 10),
      cancelOnError: true,
      partialResults: true, // Enable partial results for web
    );

    if (!isListening) {
      _errorMessage = 'Failed to start speech recognition';
      print(_errorMessage);
      notifyListeners();
      return null;
    }

    print('Listening for speech...');
    await Future.delayed(const Duration(seconds: 12));
    if (_speechToText.isNotListening && _speechToText.lastRecognizedWords.isNotEmpty) {
      print('Speech recognized: ${_speechToText.lastRecognizedWords}');
      return _speechToText.lastRecognizedWords;
    }

    _errorMessage = 'No speech recognized or recognition failed';
    print(_errorMessage);
    notifyListeners();
    return null;
  }

  void recordQuizPerformance(String category, bool isCorrect) {
    if (!_categoryPerformance.containsKey(category)) {
      _categoryPerformance[category] = 0;
    }
    _categoryPerformance[category] = _categoryPerformance[category]! + (isCorrect ? 1 : -1);
    notifyListeners();
  }

  String? getPersonalizedFocus() {
    if (_categoryPerformance.isEmpty) return null;
    var worstCategory = _categoryPerformance.entries.reduce((a, b) => a.value < b.value ? a : b);
    if (worstCategory.value < 0) {
      return worstCategory.key;
    }
    return null;
  }

  Future<void> fetchExercisesForStage(String stage) async {
    if (_targetLanguage == null) {
      _errorMessage = 'Please select a target language first';
      notifyListeners();
      throw Exception(_errorMessage);
    }

    _selectedCategory = stage;
    final queries = _getStagePhrases(stage);

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
              category: stage,
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

  List<String> _getStagePhrases(String stage) {
    switch (stage) {
      case 'Beginner':
        return phraseCategories['Greetings & Introductions'] ?? [];
      case 'Intermediate':
        return phraseCategories['Everyday Basics'] ?? [];
      case 'Advanced':
        return phraseCategories['Making Plans'] ?? [];
      default:
        return [];
    }
  }

  void completeExercise(String stage, bool isCorrect) {
    if (!_stageProgress.containsKey(stage)) {
      _stageProgress[stage] = 0;
    }
    _stageProgress[stage] = _stageProgress[stage]! + (isCorrect ? 1 : 0);
    if (_stageProgress[stage]! >= 5) {
      _currentStage = min(_currentStage + 1, stages.length - 1); // Using min from dart:math
    }
    notifyListeners();
  }

  // Setter for currentStage (optional, if needed externally)
  set currentStage(int value) {
    _currentStage = value;
    notifyListeners();
  }
  // New method to save quiz progress
  Future<void> saveQuizProgress(String userId, String language, Map<String, dynamic> quizData) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/progress'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'language': language,
          'quizData': quizData,
        }),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to save progress: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saving quiz progress: $e');
    }
  }
}
