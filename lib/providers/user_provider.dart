import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isDarkMode = false;
  String _language = 'en';

  UserProfile? get userProfile => _userProfile;
  bool get isDarkMode => _isDarkMode;
  String get language => _language;

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  void updateUserProfile(UserProfile updatedProfile) {
    _userProfile = updatedProfile;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLanguage(String language) {
    _language = language;
    notifyListeners();
  }

  void updatePreferences(Map<String, dynamic> preferences) {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(
        preferences: {..._userProfile!.preferences, ...preferences},
      );
      notifyListeners();
    }
  }
}

