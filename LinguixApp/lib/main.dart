import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
import 'src/config/theme.dart';
import 'src/screens/progressScreen.dart';
import 'src/services/mongo_service.dart';
import 'src/models/user_profile.dart';
import 'src/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileAdapter());

  // Initialize Firebase with correct options
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
      databaseURL: "https://languagelearningapp-9d48b.firebaseio.com", // Add this line
    )
        : null,
  );

  // Insert sample assignments into MongoDB
  final mongoService = MongoService();
  try {
    await mongoService.insertSampleAssignments();
  } catch (e) {
    print('Error inserting sample assignments: $e');
  }

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
        theme: AppTheme.theme,
        initialRoute: '/',
        debugShowCheckedModeBanner: false,
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
          '/progress': (context) => const ProgressScreen(),
          '/profile': (context) => const ProfileScreen(),

        },
      ),
    );
  }
}

// Hive Type Adapter for UserProfile
class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    return UserProfile(
      id: reader.readString(),
      name: reader.readString(),
      avatar: reader.readString(),
      country: reader.readString(),
      xp: reader.readInt(),
      streak: reader.readInt(),
      badges: reader.readStringList(),
      languages: reader.readStringList(),
      progress: reader.readMap().cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.avatar);
    writer.writeString(obj.country);
    writer.writeInt(obj.xp);
    writer.writeInt(obj.streak);
    writer.writeStringList(obj.badges);
    writer.writeStringList(obj.languages);
    writer.writeMap(obj.progress);
  }
}