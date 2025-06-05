import 'package:flutter/foundation.dart';

class ChallengeProvider with ChangeNotifier {
  String? _activeChallenge;
  int _challengeScore = 0;

  String? get activeChallenge => _activeChallenge;
  int get challengeScore => _challengeScore;

  void startChallenge(String challenge) {
    _activeChallenge = challenge;
    _challengeScore = 0;
    notifyListeners();
  }

  void updateChallengeScore(int score) {
    _challengeScore += score;
    notifyListeners();
  }

  void endChallenge() {
    _activeChallenge = null;
    notifyListeners();
  }
}