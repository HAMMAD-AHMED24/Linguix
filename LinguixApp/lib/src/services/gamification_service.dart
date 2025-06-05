import 'package:hive/hive.dart'; // Add this if using Hive
import 'package:hive_flutter/hive_flutter.dart'; // Add this if using Hive Flutter
import '../models/user_profile.dart';

class GamificationService {
  late Box<UserProfile> _userBox; // Declare as late Box<UserProfile>

  // Initialize Hive and open the box
  Future<void> init() async {
    await Hive.initFlutter(); // Initialize Hive
    _userBox = await Hive.openBox<UserProfile>('userprofile'); // Open the box
    print('Got object store box in database userprofile.'); // Debug log
  }

  // Constructor to ensure init is called
  GamificationService() {
    init(); // Call init during construction
  }

  // Get user profile (ensure _userBox is ready)
  Future<UserProfile?> getUserProfile(String uid) async {
    if (!_userBox.isOpen) {
      await init(); // Reinitialize if not open (fallback)
    }
    return _userBox.get(uid) ?? UserProfile(id: uid, name: 'User');
  }

  // Optional: Save user profile
  Future<void> saveUserProfile(UserProfile user) async {
    await _userBox.put(user.id, user);
  }
}