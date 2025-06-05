import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../config/theme.dart';
import '../services/mongo_service.dart';
import '../providers/auth_provider.dart';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedOption;
  bool _showResult = false;
  String _selectedCategory = 'Greetings & Introductions'; // Default category
  bool _isLoading = false;
  List<Map<String, dynamic>> _filteredQuizzes = [];

  @override
  void initState() {
    super.initState();
    // Load quizzes for default category if target language is set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Provider.of<LanguageProvider>(context, listen: false).targetLanguage != null) {
        _fetchQuizzesForCategory(_selectedCategory);
      }
    });
  }

  Future<void> _fetchQuizzesForCategory(String category) async {
    setState(() {
      _isLoading = true;
    });

    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    try {
      await languageProvider.fetchTranslations(category: category);
      await languageProvider.fetchQuizzes();

      final quizzes = languageProvider.quizzes;
      final filtered = quizzes.where((quiz) => quiz.category == category).toList();

      final randomized = filtered.map((quiz) {
        final options = List<String>.from(quiz.options);
        options.shuffle(Random());
        return {
          ...quiz.toMap(),
          'options': options,
          'category': category,
        };
      }).toList();

      setState(() {
        _selectedCategory = category;
        _filteredQuizzes = randomized;
        _currentIndex = 0;
        _score = 0;
        _selectedOption = null;
        _showResult = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading quizzes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final categories = languageProvider.categories;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: AppTheme.primaryNavy,
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          width: double.infinity,
          height: MediaQuery.of(context).size.height, // Explicitly set to screen height
          child: const Center(child: CircularProgressIndicator(color: AppTheme.accentTeal)),
        ),
      );
    }

    // Show message if target language is not set
    if (languageProvider.targetLanguage == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Select Language'),
          backgroundColor: AppTheme.primaryNavy,
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          width: double.infinity,
          height: MediaQuery.of(context).size.height, // Explicitly set to screen height
          padding: const EdgeInsets.all(24.0),
          child: const Center(
            child: Text(
              'Please select a target language from the Home Screen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Show message if no quizzes are available for default category
    if (_filteredQuizzes.isEmpty && _selectedCategory == 'Greetings & Introductions') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          backgroundColor: AppTheme.primaryNavy,
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          width: double.infinity,
          height: MediaQuery.of(context).size.height, // Explicitly set to screen height
          child: const Center(
            child: Text(
              'No quizzes available in this category',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    // Show category dropdown if no quizzes are loaded
    if (_filteredQuizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Select Quiz Category'),
          backgroundColor: AppTheme.primaryNavy,
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          width: double.infinity,
          height: MediaQuery.of(context).size.height, // Explicitly set to screen height
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey[800], // Darker background for better contrast
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                dropdownColor: Colors.grey[800], // Match container background
                style: const TextStyle(
                  color: Colors.white, // White text for dropdown
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                hint: const Text(
                  'Choose a category',
                  style: TextStyle(color: Colors.white70),
                ),
                icon: const Icon(Icons.arrow_drop_down, color: AppTheme.accentTeal),
                underline: Container(
                  height: 2,
                  color: AppTheme.accentTeal,
                ),
                items: categories.map((String cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(
                      cat,
                      style: const TextStyle(
                        color: Colors.white, // White text for items
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _fetchQuizzesForCategory(value);
                  }
                },
              ),
            ),
          ),
        ),
      );
    }

    final currentQuiz = _filteredQuizzes[_currentIndex];
    final options = List<String>.from(currentQuiz['options']);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quiz (${_currentIndex + 1}/${_filteredQuizzes.length})',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryNavy,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              value: _selectedCategory,
              dropdownColor: Colors.grey[800], // Darker background for better contrast
              style: const TextStyle(
                color: Colors.white, // White text for dropdown
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.accentTeal),
              underline: Container(),
              items: categories.map((String cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(
                    cat,
                    style: const TextStyle(
                      color: Colors.white, // White text for items
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _fetchQuizzesForCategory(value);
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        width: double.infinity,
        height: MediaQuery.of(context).size.height, // Explicitly set to screen height
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white, // Ensure card stands out against gradient
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          currentQuiz['question'],
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppTheme.primaryNavy,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, size: 24, color: AppTheme.accentTeal),
                        onPressed: () {
                          final sourcePhrase = currentQuiz['question'].split('"')[1];
                          languageProvider.speak(sourcePhrase, 'en');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ...options.map((option) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  color: Colors.white, // Ensure options stand out against gradient
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                              option,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.primaryNavy,
                                fontSize: 18,
                              ),
                            ),
                            value: option,
                            groupValue: _selectedOption,
                            onChanged: _showResult
                                ? null
                                : (value) {
                              setState(() => _selectedOption = value);
                            },
                            activeColor: AppTheme.accentTeal,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 20, color: AppTheme.accentTeal),
                          onPressed: () {
                            languageProvider.speak(option, languageProvider.targetLanguage!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              if (_showResult)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: Colors.white, // Ensure result stands out
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _selectedOption == currentQuiz['correct']
                          ? 'Correct! 🎉'
                          : 'Incorrect. The correct answer is: ${currentQuiz['correct']}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _selectedOption == currentQuiz['correct'] ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              if (!_showResult && _selectedOption != null)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showResult = true;
                      if (_selectedOption == currentQuiz['correct']) {
                        _score++;
                      }
                      languageProvider.recordQuizPerformance(
                        _selectedCategory,
                        _selectedOption == currentQuiz['correct'],
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Submit'),
                ),
              if (_showResult)
                ElevatedButton(
                  onPressed: () async {
                    if (_currentIndex < _filteredQuizzes.length - 1) {
                      setState(() {
                        _currentIndex++;
                        _selectedOption = null;
                        _showResult = false;
                      });
                    } else {
                      if (authProvider.user != null) {
                        await MongoService().saveQuizProgress(
                          authProvider.user!.uid,
                          languageProvider.targetLanguage ?? 'unknown',
                          _score,
                          _filteredQuizzes.length,
                          DateTime.now(),
                        );
                      }
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppTheme.softWhite,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          title: Text(
                            'Quiz Complete!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.primaryNavy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Your score: $_score/${_filteredQuizzes.length}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.primaryNavy,
                              fontSize: 18,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text(
                                'OK',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.accentGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: AppTheme.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(_currentIndex < _filteredQuizzes.length - 1 ? 'Next' : 'Finish'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}