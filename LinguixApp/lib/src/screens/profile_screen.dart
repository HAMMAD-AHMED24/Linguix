import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/gamification_service.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final gamificationService = GamificationService();

    return FutureBuilder(
      future: gamificationService.getUserProfile(authProvider.user!.uid),
      builder: (context, AsyncSnapshot<UserProfile?> snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final user = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(radius: 50, backgroundImage: NetworkImage(user.avatar)),
              const SizedBox(height: 10),
              Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
              Text('${user.country} | ${user.languages.join(", ")}'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatCard(title: 'XP', value: user.xp.toString()),
                  _StatCard(title: 'Streak', value: '${user.streak} days'),
                  _StatCard(title: 'Badges', value: user.badges.length.toString()),
                ],
              ),
              const SizedBox(height: 20),
              Text('XP Growth', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: 1000,
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 100),
                          const FlSpot(1, 200),
                          const FlSpot(2, 400),
                          const FlSpot(3, 500),
                          const FlSpot(4, 700),
                          const FlSpot(5, 900),
                          FlSpot(6, user.xp.toDouble()),
                        ],
                        isCurved: true,
                        color: Colors.blue,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}