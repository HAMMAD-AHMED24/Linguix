import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../config/theme.dart';

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

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final quizzes = languageProvider.quizzes;

    if (quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Quiz',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: const Center(
            child: Text(
              'No quizzes available',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    final currentQuiz = quizzes[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quiz (${_currentIndex + 1}/${quizzes.length})',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient, // Navy-to-black gradient
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          currentQuiz.question,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.primaryNavy,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, size: 20),
                        color: AppTheme.accentTeal,
                        onPressed: () {
                          final sourcePhrase = currentQuiz.question.split('"')[1];
                          languageProvider.speak(sourcePhrase, 'en');
                        },
                        tooltip: 'Play English pronunciation',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...currentQuiz.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                              option,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                            value: option,
                            groupValue: _selectedOption,
                            onChanged: _showResult
                                ? null
                                : (value) {
                              setState(() {
                                _selectedOption = value;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 20),
                          color: AppTheme.accentTeal,
                          onPressed: () {
                            languageProvider.speak(option, languageProvider.targetLanguage!);
                          },
                          tooltip: 'Play target language pronunciation',
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              if (_showResult)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _selectedOption == currentQuiz.correct
                          ? 'Correct!'
                          : 'Incorrect. The correct answer is: ${currentQuiz.correct}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _selectedOption == currentQuiz.correct ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (!_showResult && _selectedOption != null)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showResult = true;
                      if (_selectedOption == currentQuiz.correct) {
                        _score++;
                      }
                      // Record performance
                      languageProvider.recordQuizPerformance(
                        languageProvider.selectedCategory!,
                        _selectedOption == currentQuiz.correct,
                      );
                    });
                  },
                  child: const Text('Submit'),
                ),
              if (_showResult)
                ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < quizzes.length - 1) {
                      setState(() {
                        _currentIndex++;
                        _selectedOption = null;
                        _showResult = false;
                      });
                    } else {
                      // Save progress when quiz is complete
                      final quizData = {
                        'score': (_score / quizzes.length * 100).round(),
                        'completed': true,
                        'date': DateTime.now().toIso8601String(),
                        'totalQuestions': quizzes.length,
                        'correctAnswers': _score,
                      };
                      languageProvider.saveQuizProgress(
                        'guest_user', // Static userId; replace with dynamic if needed
                        languageProvider.targetLanguage ?? 'en',
                        quizData,
                      ).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Quiz progress saved!')),
                        );
                      }).catchError((e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving progress: $e')),
                        );
                      });

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppTheme.softWhite,
                          title: Text(
                            'Quiz Complete!',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          content: Text(
                            'Your score: $_score/${quizzes.length} (${( _score / quizzes.length * 100).round()}%)',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.primaryNavy,
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
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Text(_currentIndex < quizzes.length - 1 ? 'Next' : 'Finish'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}