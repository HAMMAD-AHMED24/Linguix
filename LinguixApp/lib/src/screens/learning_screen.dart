import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../config/theme.dart';
import '../models/language.dart';
import '../models/quiz.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LearningScreen extends StatefulWidget {
  const LearningScreen({Key? key}) : super(key: key);

  @override
  _LearningScreenState createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  int _currentQuestionIndex = 0;
  String? _userAnswer;
  bool _showResult = false;
  bool _isLoading = true;
  String? _suggestedWord;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _suggestedWord = arguments?['suggestedWord'] as String?;
      _loadExercises();
    });
  }

  Future<void> _loadExercises() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    try {
      setState(() => _isLoading = true);
      if (_suggestedWord != null && languageProvider.targetLanguage != null) {
        await languageProvider.fetchQuizForWord(languageProvider.targetLanguage!, _suggestedWord!);
      } else {
        await languageProvider.fetchExercisesForStage(LanguageProvider.stages[languageProvider.currentStage]);
        await languageProvider.fetchQuizzes();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading quiz: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _checkAnswer(bool isCorrect) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.completeExercise(LanguageProvider.stages[languageProvider.currentStage], isCorrect);
    languageProvider.recordQuizPerformance(
      languageProvider.quizzes[_currentQuestionIndex].category,
      isCorrect,
    );
    setState(() {
      _showResult = true;
    });
    _nextQuestion();
  }

  void _nextQuestion() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    if (_currentQuestionIndex < languageProvider.quizzes.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _userAnswer = null;
        _showResult = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
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
          'Move to the next stage?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.primaryNavy,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextStage();
            },
            child: Text(
              'Yes',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.accentGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.accentTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStage() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    if (languageProvider.currentStage < LanguageProvider.stages.length - 1) {
      languageProvider.currentStage = languageProvider.currentStage + 1;
      _loadExercises();
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    if (_isLoading || languageProvider.quizzes.isEmpty || languageProvider.targetLanguage == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          backgroundColor: AppTheme.primaryNavy,
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    final currentQuiz = languageProvider.quizzes[_currentQuestionIndex];
    final isSuggested = _suggestedWord != null && currentQuiz.correct == _suggestedWord;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz - ${LanguageProvider.stages[languageProvider.currentStage]}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryNavy,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1}/${languageProvider.quizzes.length}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.primaryNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentQuiz.question,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.primaryNavy,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isSuggested)
                      Text(
                        'AI-Suggested Word',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.accentTeal,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: currentQuiz.options.map((option) {
                  return Card(
                    color: _showResult
                        ? (option == currentQuiz.correct ? Colors.green[100] : Colors.red[100])
                        : Colors.white,
                    child: ListTile(
                      title: Text(
                        option,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      onTap: _showResult
                          ? null
                          : () {
                        setState(() {
                          _userAnswer = option;
                        });
                      },
                      trailing: _userAnswer == option
                          ? const Icon(Icons.check_circle, color: AppTheme.accentTeal)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            if (_showResult)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _userAnswer == currentQuiz.correct
                        ? 'Correct! 🎉'
                        : 'Incorrect. The correct answer is: ${currentQuiz.correct}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _userAnswer == currentQuiz.correct ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showResult || _userAnswer == null
                  ? null
                  : () => _checkAnswer(_userAnswer == currentQuiz.correct),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}