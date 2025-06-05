import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/mongo_service.dart';
import '../config/theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<List<Map<String, dynamic>>> _progressFuture;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _progressFuture = MongoService().getQuizProgress(authProvider.user!.uid);
    } else {
      _progressFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Progress',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _progressFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading progress',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
                  ),
                );
              }
              final progressList = snapshot.data ?? [];
              if (progressList.isEmpty) {
                return Center(
                  child: Text(
                    authProvider.user != null
                        ? 'No progress recorded yet'
                        : 'Please log in to view progress',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                );
              }
              return ListView.builder(
                itemCount: progressList.length,
                itemBuilder: (context, index) {
                  final progress = progressList[index];
                  final score = progress['score'];
                  final total = progress['total'];
                  final language = progress['language'];
                  final date = DateTime.parse(progress['date']).toLocal();
                  return Card(
                    child: ListTile(
                      title: Text(
                        'Quiz: $language',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.primaryNavy),
                      ),
                      subtitle: Text(
                        'Score: $score/$total (${(score / total * 100).toStringAsFixed(1)}%) - Date: ${date.toString().split(' ')[0]}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryNavy),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}