import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/model/user_model.dart';

class UserService {
  static const String userKey = "current_user";

  // Get current user from shared preferences
  static Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(userKey);
      if (userJson != null) {
        return UserModel.fromJson(userJson);
      }
      return null;
    } catch (e) {
      debugPrint("Error getting user data: $e");
      return null;
    }
  }

  // Save user to shared preferences
  static Future<bool> saveUserLocally(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(userKey, user.toJson());
      return true;
    } catch (e) {
      debugPrint("Error saving user data locally: $e");
      return false;
    }
  }

  // Clear user login status
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return true;
    } catch (e) {
      debugPrint("Error clearing user data: $e");
      return false;
    }
  }
}
