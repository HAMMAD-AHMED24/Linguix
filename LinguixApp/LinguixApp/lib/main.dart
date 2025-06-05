import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/language_provider.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/quiz_screen.dart';
import 'src/screens/assignment_screen.dart';
import 'src/screens/language_selection_screen.dart';
import 'src/screens/learning_screen.dart';
import 'src/screens/speech_translation_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'src/screens/ARModeScreen.dart';
import 'src/screens/splash_screen.dart';
import 'src/config/theme.dart'; // Import the theme file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
      apiKey: "AIzaSyDCMKswnLrTAfP2MAnw5Evi0ddSKuUeULE",
      appId: "1:581157726653:android:a0137ae564b16d7c2f0ad4",
      messagingSenderId: "your-sender-id",
      projectId: "languagelearningapp-9d48b",
      authDomain: "languagelearningapp-9d48b.firebaseapp.com",
      storageBucket: "languagelearningapp-9d48b.appspot.com",
      measurementId: "your-measurement-id",
    )
        : null,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<LanguageProvider>(create: (_) => LanguageProvider()),
      ],
      child: MaterialApp(
        title: 'Language Learning App',
        theme: AppTheme.theme, // Use the chic theme from theme.dart
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/quiz': (context) => const QuizScreen(),
          '/assignment': (context) => const AssignmentScreen(),
          '/language-selection': (context) => const LanguageSelectionScreen(),
          '/learning': (context) => const LearningScreen(),
          '/speech-translation': (context) => const SpeechTranslationScreen(),
          '/ar_mode': (context) => const ARModeScreen(),
        },
      ),
    );
  }
}