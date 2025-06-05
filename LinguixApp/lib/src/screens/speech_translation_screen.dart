import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../providers/language_provider.dart';
import '../config/theme.dart';

class SpeechTranslationScreen extends StatefulWidget {
  const SpeechTranslationScreen({Key? key}) : super(key: key);

  @override
  _SpeechTranslationScreenState createState() => _SpeechTranslationScreenState();
}

class _SpeechTranslationScreenState extends State<SpeechTranslationScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _speechText = '';
  Future<void>? _translateFuture;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await Permission.microphone.request();
    await _speech.initialize();
  }

  void _startListening() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    setState(() {
      _isListening = true;
      _speechText = '';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _speechText = result.recognizedWords;
        });
      },
      localeId: languageProvider.sourceLanguage,
    );
  }

  void _stopListening() async {
    setState(() {
      _isListening = false;
    });
    await _speech.stop();

    if (_speechText.isNotEmpty) {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      setState(() {
        _translateFuture = languageProvider.translateSpeech(_speechText);
      });
    }
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
          'Speech Translation',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {},
            tooltip: 'Camera',
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {},
            tooltip: 'Microphone',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient, // Navy-to-black gradient
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Listening Status
              Text(
                _isListening ? 'Listening...' : 'Tap the mic to speak',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Spoken Text
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Spoken Text (${languageProvider.sourceLanguage}): $_speechText',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                      if (_speechText.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 20),
                          onPressed: () {
                            languageProvider.speak(_speechText, languageProvider.sourceLanguage);
                          },
                          tooltip: 'Play spoken text pronunciation',
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Translation Output
              FutureBuilder(
                future: _translateFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting || languageProvider.isLoading) {
                    return const CircularProgressIndicator(
                      color: AppTheme.accentGold,
                    );
                  }
                  if (snapshot.hasError || languageProvider.errorMessage != null) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error: ${languageProvider.errorMessage ?? snapshot.error}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.redAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (languageProvider.speechTranslation != null) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Translation (${languageProvider.targetLanguage}): ${languageProvider.speechTranslation}',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up, size: 20),
                              onPressed: () {
                                languageProvider.speak(languageProvider.speechTranslation!, languageProvider.targetLanguage!);
                              },
                              tooltip: 'Play translation pronunciation',
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 32),

              // Mic Button
              FloatingActionButton(
                onPressed: _isListening ? _stopListening : _startListening,
                child: Icon(_isListening ? Icons.mic_off : Icons.mic),
                backgroundColor: _isListening ? Colors.redAccent : AppTheme.accentTeal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}