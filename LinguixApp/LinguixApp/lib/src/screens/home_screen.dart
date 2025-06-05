import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../config/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Language Learning Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: AppTheme.accentTeal,
            onPressed: () async {
              await authProvider.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
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
              Text(
                'Welcome to LinguixApp',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Card(
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
              const SizedBox(height: 32),
              Card(
                child: ListTile(
                  title: Text(
                    'Select Language to Learn',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward,
                    color: AppTheme.accentTeal,
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/language-selection');
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: Text(
                    'Take a Quiz',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward,
                    color: AppTheme.accentTeal,
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/quiz');
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: Text(
                    'Practice Speech Translation',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward,
                    color: AppTheme.accentTeal,
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/speech-translation');
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: Text(
                    'View Assignments',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward,
                    color: AppTheme.accentTeal,
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/assignment');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}