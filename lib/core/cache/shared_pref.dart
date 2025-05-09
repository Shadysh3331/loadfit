import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferences? _preferences;

  static Future initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Setters
  static Future<bool> setValue<T>(String key, T value) async {
    if (_preferences == null) return false;
    if (value is int) {
      return _preferences!.setInt(key, value);
    } else if (value is String) {
      return _preferences!.setString(key, value);
    } else if (value is bool) {
      return _preferences!.setBool(key, value);
    } else if (value is double) {
      return _preferences!.setDouble(key, value);
    } else {
      throw Exception("Invalid type");
    }
  }

  // Getters
  static T? getValue<T>(String key) {
    if (_preferences == null) return null;
    if (T == int || T == String || T == bool || T == double) {
      return _preferences!.get(key) as T?;
    } else {
      throw Exception("Invalid type");
    }
  }

  // Delete data
  static Future<bool> removeValue(String key) async {
    if (_preferences == null) return false;
    return _preferences!.remove(key);
  }
}
