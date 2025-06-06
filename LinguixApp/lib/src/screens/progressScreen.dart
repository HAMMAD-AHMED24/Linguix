import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends StatefulWidget {
  final String userId;
  final String language;
  const ProgressScreen({Key? key, required this.userId, required this.language}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<List<dynamic>> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = fetchProgress();
  }

  Future<List<dynamic>> fetchProgress() async {
    final uri = Uri.parse('http://localhost:3000/api/progress/${widget.userId}/${widget.language}');
    try {
      final response = await http.get(uri);
      print('Response status: ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load progress: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch progress error: $e');
      throw Exception('Error fetching progress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Progress - ${widget.language}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _progressFuture = fetchProgress();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final progress = snapshot.data!;
          if (progress.isEmpty) {
            return const Center(child: Text('No progress found. Complete a quiz to see your progress!'));
          }
          // Sort progress by timestamp
          progress.sort((a, b) => DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp'])));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Score Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                            reservedSize: 40,
                            interval: 20, // Adjust interval for cleaner y-axis labels
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < progress.length) {
                                return Text(
                                  'Quiz ${index + 1}',
                                  style: const TextStyle(fontSize: 12),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 30,
                            interval: 1, // Ensure each data point gets a label
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: progress
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), (e.value['quizData']['score'] as num).toDouble()))
                              .toList(),
                          isCurved: true,
                          color: Colors.blue,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                        ),
                      ],
                      minX: 0,
                      maxX: progress.length.toDouble() - 1, // Set max X based on number of quizzes
                      minY: 0,
                      maxY: 100, // Assuming scores are out of 100; adjust as needed
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Detailed Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: progress.length,
                  itemBuilder: (context, index) {
                    final item = progress[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text('Score: ${item['quizData']['score'] ?? 'N/A'}'),
                        subtitle: Text('Date: ${item['timestamp']}'),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}