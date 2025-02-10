class Settings {
  String username;
  String serverUrl;
  String customMessage;

  Settings({
    this.username = 'You',
    this.serverUrl = 'http://localhost:3000',
    this.customMessage = '{user} says hello!',
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'serverUrl': serverUrl,
    'customMessage': customMessage,
  };

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    username: json['username'] ?? 'User',
    serverUrl: json['serverUrl'] ?? 'http://localhost:8080',
    customMessage: json['customMessage'] ?? 'Knock knock!',
  );
}
