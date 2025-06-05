import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../config/theme.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({Key? key}) : super(key: key);

  @override
  _LearningScreenState createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  Future<void>? _fetchTranslationsFuture;
  String _selectedCategory = 'Greetings & Introductions';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      languageProvider.setSelectedCategory(_selectedCategory);
      _fetchTranslationsFuture = languageProvider.fetchTranslations(category: _selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Learn ${languageProvider.targetLanguage} from English',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            color: AppTheme.accentTeal,
            onPressed: () {
              Navigator.pushNamed(context, '/ar_mode');
            },
            tooltip: 'AR Mode',
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            color: AppTheme.accentTeal,
            onPressed: () {
              Navigator.pushNamed(context, '/speech-translation');
            },
            tooltip: 'Speech Translation',
          ),
          IconButton(
            icon: const Icon(Icons.quiz),
            color: AppTheme.accentTeal,
            onPressed: () async {
              await languageProvider.fetchQuizzes();
              Navigator.pushNamed(context, '/quiz');
            },
            tooltip: 'Take Quiz',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient, // Navy-to-black gradient
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Select Category:',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.primaryNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          dropdownColor: AppTheme.softWhite,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.primaryNavy,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCategory = newValue;
                                languageProvider.setSelectedCategory(newValue);
                                _fetchTranslationsFuture =
                                    languageProvider.fetchTranslations(category: newValue);
                              });
                            }
                          },
                          items: LanguageProvider.phraseCategories.keys
                              .map<DropdownMenuItem<String>>((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (languageProvider.getPersonalizedFocus() != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Personalized Focus: Practice "${languageProvider.getPersonalizedFocus()}" to improve!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.accentTeal,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            if (languageProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      languageProvider.errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.redAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'API Requests Used: ${languageProvider.requestCount}/50 (Free Tier Daily Limit)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _fetchTranslationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      languageProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentGold,
                      ),
                    );
                  }
                  if (snapshot.hasError || languageProvider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${languageProvider.errorMessage ?? snapshot.error}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _fetchTranslationsFuture = Provider.of<LanguageProvider>(context,
                                    listen: false)
                                    .fetchTranslations(category: _selectedCategory);
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (languageProvider.translations.isEmpty) {
                    return const Center(
                      child: Text(
                        'No translations available',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: languageProvider.translations.length,
                    itemBuilder: (context, index) {
                      final translation = languageProvider.translations[index];
                      return Card(
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  translation.query,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.primaryNavy,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up, size: 20),
                                color: AppTheme.accentTeal,
                                onPressed: () {
                                  languageProvider.speak(translation.query, 'en');
                                },
                                tooltip: 'Play English pronunciation',
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Translation: ${translation.translation}',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.primaryNavy,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up, size: 20),
                                color: AppTheme.accentTeal,
                                onPressed: () {
                                  languageProvider.speak(
                                      translation.translation, languageProvider.targetLanguage!);
                                },
                                tooltip: 'Play target language pronunciation',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}