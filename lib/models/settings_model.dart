import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static Settings? _instance;
  static Settings get instance => _instance ??= Settings._();

  String username;
  String serverUrl;
  String customMessage;
  String get parsedMessage => customMessage.replaceAll('{user}', username);
  bool allowHaptics;

  Settings._({
    this.username = 'You',
    this.serverUrl = 'http://localhost:3000',
    this.customMessage = '{user} says hello!',
    this.allowHaptics = true,
  });


  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final String settingsJson = prefs.getString('settings') ?? '{}';
    return jsonDecode(settingsJson)['username'];
  }
  
  static Future<void> initialize() async {
    if (_instance != null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString('settings');

    if (settingsJson != null) {
      final Map<String, dynamic> json = jsonDecode(settingsJson);
      _instance = Settings._(
        username: json['username'] ?? 'User',
        serverUrl: json['serverUrl'] ?? 'http://localhost:8080',
        customMessage: json['customMessage'] ?? 'Knock knock!',
        allowHaptics: json["allowHaptics"] ?? true,
      );
    } else {
      _instance = Settings._();
    }
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', jsonEncode({
      'username': instance.username,
      'serverUrl': instance.serverUrl,
      'customMessage': instance.customMessage,
      'allowHaptics': instance.allowHaptics,
    }));
  }
}
