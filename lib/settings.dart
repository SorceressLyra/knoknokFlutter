import 'package:flutter/material.dart';
import 'package:knoknok_mobile/connection_handler.dart';
import 'package:url_launcher/url_launcher.dart';
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

  @override
  void initState() {
    super.initState();

    _isConnected = ConnectionHandler.connectionStatus.value;
    ConnectionHandler.connectionStatus.addListener(() {
     try {
        setState(() {
          _isConnected = ConnectionHandler.connectionStatus.value;
        });
      } catch (e) {
        print(e);
      }
    });

    _usernameController =
        TextEditingController(text: Settings.instance.username);
    _serverController =
        TextEditingController(text: Settings.instance.serverUrl);
    _messageController =
        TextEditingController(text: Settings.instance.customMessage);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _serverController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    Settings.instance.username = _usernameController.text;
    Settings.instance.serverUrl = _serverController.text;
    Settings.instance.customMessage = _messageController.text;
    await Settings.save();

    ConnectionHandler.reconnect();
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
          onSubmitted: (_) => _saveSettings(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _serverController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Server URL',
          ),
          onSubmitted: (_) => _saveSettings(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _messageController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Custom message',
          ),
          onSubmitted: (_) => _saveSettings(),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            title: const Text('Connection status'),
            subtitleTextStyle: TextStyle(
              color: _isConnected ? Colors.green : Colors.red,
            ),
            subtitle: Text(_isConnected ? 'Connected' : 'Disconnected'),
            trailing: IconButton.filled(
                isSelected: false,
                onPressed: () => {ConnectionHandler.reconnect()},
                icon: Icon(Icons.refresh)),
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
                        final url =
                            Uri.parse("https://github.com/SorceressLyra");
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      icon: const Icon(Icons.link),
                      label: const Text('Github'))
                ]),
          },
          icon: Icon(Icons.info),
          label: const Text('About'),
        ),
      ],
    );
  }
}
