import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../config/theme.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Map<String, String> languageMap = {
    'af': 'Afrikaans', 'sq': 'Albanian', 'am': 'Amharic', 'ar': 'Arabic', 'hy': 'Armenian',
    'az': 'Azerbaijani', 'eu': 'Basque', 'be': 'Belarusian', 'bn': 'Bengali', 'bs': 'Bosnian',
    'bg': 'Bulgarian', 'ca': 'Catalan', 'ceb': 'Cebuano', 'ny': 'Chichewa', 'zh-CN': 'Chinese (Simplified)',
    'zh-TW': 'Chinese (Traditional)', 'co': 'Corsican', 'hr': 'Croatian', 'cs': 'Czech', 'da': 'Danish',
    'nl': 'Dutch', 'en': 'English', 'eo': 'Esperanto', 'et': 'Estonian', 'tl': 'Filipino',
    'fi': 'Finnish', 'fr': 'French', 'fy': 'Frisian', 'gl': 'Galician', 'ka': 'Georgian',
    'de': 'German', 'el': 'Greek', 'gu': 'Gujarati', 'ht': 'Haitian Creole', 'ha': 'Hausa',
    'haw': 'Hawaiian', 'iw': 'Hebrew', 'hi': 'Hindi', 'hmn': 'Hmong', 'hu': 'Hungarian',
    'is': 'Icelandic', 'ig': 'Igbo', 'id': 'Indonesian', 'ga': 'Irish', 'it': 'Italian',
    'ja': 'Japanese', 'jw': 'Javanese', 'kn': 'Kannada', 'kk': 'Kazakh', 'km': 'Khmer',
    'rw': 'Kinyarwanda', 'ko': 'Korean', 'ku': 'Kurdish (Kurmanji)', 'ky': 'Kyrgyz', 'lo': 'Lao',
    'la': 'Latin', 'lv': 'Latvian', 'lt': 'Lithuanian', 'lb': 'Luxembourgish', 'mk': 'Macedonian',
    'mg': 'Malagasy', 'ms': 'Malay', 'ml': 'Malayalam', 'mt': 'Maltese', 'mi': 'Maori',
    'mr': 'Marathi', 'mn': 'Mongolian', 'my': 'Myanmar (Burmese)', 'ne': 'Nepali', 'no': 'Norwegian',
    'or': 'Odia (Oriya)', 'ps': 'Pashto', 'fa': 'Persian', 'pl': 'Polish', 'pt': 'Portuguese',
    'pa': 'Punjabi', 'ro': 'Romanian', 'ru': 'Russian', 'sm': 'Samoan', 'gd': 'Scots Gaelic',
    'sr': 'Serbian', 'st': 'Sesotho', 'sn': 'Shona', 'sd': 'Sindhi', 'si': 'Sinhala',
    'sk': 'Slovak', 'sl': 'Slovenian', 'so': 'Somali', 'es': 'Spanish', 'su': 'Sundanese',
    'sw': 'Swahili', 'sv': 'Swedish', 'tg': 'Tajik', 'ta': 'Tamil', 'te': 'Telugu',
    'th': 'Thai', 'tr': 'Turkish', 'uk': 'Ukrainian', 'ur': 'Urdu', 'ug': 'Uyghur',
    'uz': 'Uzbek', 'vi': 'Vietnamese', 'cy': 'Welsh', 'xh': 'Xhosa', 'yi': 'Yiddish',
    'yo': 'Yoruba', 'zu': 'Zulu', 'as': 'Assamese', 'br': 'Breton', 'dz': 'Dzongkha',
    'ff': 'Fulah', 'kl': 'Kalaallisut', 'ks': 'Kashmiri', 'iu': 'Inuktitut', 'gv': 'Manx',
    'to': 'Tongan', 'vo': 'Volapük',
  };

  bool _isDarkMode = false;
  final APIService _apiService = APIService();
  late Future<Map<String, String>> _suggestionFuture;

  @override
  void initState() {
    super.initState();
    _suggestionFuture = _loadSuggestion();
  }

  Future<Map<String, String>> _loadSuggestion() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    return _apiService.getQuizSuggestion(
      languageProvider.targetLanguage ?? 'en', // Default to English if none selected
      'vocabulary', // Default weak area
      0, // Default XP
    );
  }

  void _refreshSuggestion() {
    setState(() {
      _suggestionFuture = _loadSuggestion();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageProvider = Provider.of<LanguageProvider>(context);
    if (languageProvider.targetLanguage != null) {
      setState(() {
        _suggestionFuture = _loadSuggestion();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isLoading = languageProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Language Learning Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            color: AppTheme.accentTeal,
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
        backgroundColor: AppTheme.primaryNavy,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Guest User',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: AppTheme.primaryNavy),
                              ),
                              Text(
                                'XP: 0 | Streak: 0 days',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: AppTheme.primaryNavy),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome to LinguixApp',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: DropdownButton<String>(
                      value: languageProvider.targetLanguage,
                      isExpanded: true,
                      dropdownColor: AppTheme.softWhite,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppTheme.primaryNavy),
                      hint: const Text('Select Language to Learn'),
                      items: languageMap.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          languageProvider.setTargetLanguage(newValue);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, String>>(
                  future: _suggestionFuture,
                  builder: (context, suggestionSnapshot) {
                    if (suggestionSnapshot.connectionState == ConnectionState.waiting) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }
                    if (suggestionSnapshot.hasError) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            suggestionSnapshot.error.toString().contains('rate limit')
                                ? 'API rate limit exceeded. Please try again later.'
                                : 'Error loading suggestion: ${suggestionSnapshot.error}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppTheme.primaryNavy),
                          ),
                        ),
                      );
                    }
                    final suggestion = suggestionSnapshot.data?['suggestion'] ??
                        'Practice vocabulary with a quiz!';
                    final word = suggestionSnapshot.data?['word'] ?? 'Hello';

                    return Column(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Icon(Icons.lightbulb, color: AppTheme.accentTeal),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'AI Tutor: $suggestion',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(color: AppTheme.primaryNavy),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh, color: AppTheme.accentTeal),
                                  onPressed: _refreshSuggestion,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Icon(Icons.book, color: AppTheme.accentTeal),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Quiz Word: $word',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(color: AppTheme.primaryNavy),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up, color: AppTheme.accentTeal),
                                  onPressed: () async {
                                    final languageProvider =
                                    Provider.of<LanguageProvider>(context, listen: false);
                                    if (languageProvider.targetLanguage != null) {
                                      await languageProvider.speak(
                                        word,
                                        languageProvider.targetLanguage!,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Please select a target language first')),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward, color: AppTheme.accentTeal),
                                  onPressed: () async {
                                    final navigator = Navigator.of(context);
                                    final languageProvider =
                                    Provider.of<LanguageProvider>(context, listen: false);
                                    if (!mounted) return;

                                    if (languageProvider.targetLanguage == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please select a target language first'),
                                        ),
                                      );
                                      return;
                                    }
                                    try {
                                      await languageProvider.fetchQuizForWord(
                                        languageProvider.targetLanguage!,
                                        word,
                                      );
                                      if (!mounted) return;
                                      Navigator.pushNamed(
                                        context, '/learning',
                                        arguments: {'suggestedWord': word}, // Named argument
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error loading quiz: $e')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    title: Text(
                      'Exercises of Specified Language',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppTheme.primaryNavy),
                      textAlign: TextAlign.center,
                    ),
                    trailing: const Icon(Icons.arrow_forward, color: AppTheme.accentTeal),
                    onTap: () async {
                      if (languageProvider.targetLanguage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a target language first'),
                          ),
                        );
                        return;
                      }
                      await languageProvider.fetchExercisesForStage(
                        LanguageProvider.stages[languageProvider.currentStage],
                      );
                      if (mounted) {
                        Navigator.pushNamed(context, '/learning');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    title: Text(
                      'Take a Quiz',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppTheme.primaryNavy),
                      textAlign: TextAlign.center,
                    ),
                    trailing: const Icon(Icons.arrow_forward, color: AppTheme.accentTeal),
                    onTap: () async {
                      if (languageProvider.targetLanguage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a target language first'),
                          ),
                        );
                        return;
                      }
                      try {
                        await languageProvider.fetchTranslations(category: 'Greetings & Introductions');
                        await languageProvider.fetchQuizzes();
                        if (mounted) {
                          Navigator.pushNamed(context, '/quiz');
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error loading quizzes: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    title: Text(
                      'Practice Speech Translation',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppTheme.primaryNavy),
                      textAlign: TextAlign.center,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.accentTeal),
                    onTap: () {
                      if (languageProvider.targetLanguage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a target language first'),
                          ),
                        );
                        return;
                      }
                      Navigator.pushNamed(context, '/speech-translation');
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    title: Text(
                      'View Progress',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppTheme.primaryNavy),
                      textAlign: TextAlign.center,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.accentTeal),
                    onTap: () {
                      Navigator.pushNamed(context, '/progress');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
}