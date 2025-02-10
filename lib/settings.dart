import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'models/settings_model.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late bool _isConnected = false;
  late TextEditingController _usernameController;
  late TextEditingController _serverController;
  late TextEditingController _messageController;
  late Settings _settings;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _serverController = TextEditingController();
    _messageController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _serverController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString('settings');

    if (settingsJson != null) {
      setState(() {
        _settings = Settings.fromJson(jsonDecode(settingsJson));
      });
    } else {
      _settings = Settings();
    }

    _usernameController.text = _settings.username;
    _serverController.text = _settings.serverUrl;
    _messageController.text = _settings.customMessage;
  }

  Future<void> _saveSettings() async {
    _settings.username = _usernameController.text;
    _settings.serverUrl = _serverController.text;
    _settings.customMessage = _messageController.text;

    //TODO: update socket connection
    setState(() {
      _isConnected = false;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', jsonEncode(_settings.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Username',
          ),
          onChanged: (_) => _saveSettings(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _serverController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Server URL',
          ),
          onChanged: (_) => _saveSettings(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _messageController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Custom message',
          ),
          onChanged: (_) => _saveSettings(),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            title: const Text('Connection status'),
            subtitleTextStyle: TextStyle(
              color: _isConnected ? Colors.green : Colors.red,
            ),
            subtitle: Text(_isConnected ? 'Connected' : 'Disconnected'),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => {
            showAboutDialog(
                context: context,
                applicationName: 'Knoknok',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.notifications),
                children: [
                  const Text(
                      'Knoknok is a simple app to send pings to those you care about.'),
                  const SizedBox(height: 16),
                  const Text('Made with ❤️ by Lyra S.R. Mikkelsen.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                      onPressed: () async {
                        final url = Uri.parse("https://github.com/SorceressLyra");
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      icon: const Icon(Icons.link),
                      label: const Text('Github')
                  )
                ]),
          },
          icon: Icon(Icons.info),
          label: const Text('About'),
        ),
      ],
    );
  }
}
