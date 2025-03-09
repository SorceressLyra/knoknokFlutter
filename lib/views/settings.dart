import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:knoknok/controllers/socket_io_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';
import '../models/settings_model.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _usernameController;
  late TextEditingController _serverController;
  late TextEditingController _messageController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController(text: Settings.instance.username);
    _serverController = TextEditingController(text: Settings.instance.serverUrl);
    _messageController = TextEditingController(text: Settings.instance.customMessage);
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

    debugPrint('Settings saved');

    debugPrint('Reconnecting');
    SocketIOController.instance.reconnect();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: SocketIOController.instance,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                  ),
                  onSubmitted: (_) => _saveSettings(),
                  onChanged: (_) {
                    _debounceTimer?.cancel();
                    _debounceTimer = Timer(const Duration(milliseconds: 1000), _saveSettings);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _serverController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Server URL',
                  ),
                  onSubmitted: (_) => _saveSettings(),
                  onChanged: (_) {
                    _debounceTimer?.cancel();
                    _debounceTimer = Timer(const Duration(milliseconds: 1000), _saveSettings);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Default message',
                  ),
                  onSubmitted: (_) => _saveSettings(),
                  onChanged: (_) {
                    _debounceTimer?.cancel();
                    _debounceTimer = Timer(const Duration(milliseconds: 1000), _saveSettings);
                  },
                ),
                const SizedBox(height: 16),
                if (!Platform.isWindows)
                  Card(
                    child: SwitchListTile(
                        value: Settings.instance.allowHaptics,
                        onChanged: (value) async {
                          setState(() {
                            Settings.instance.allowHaptics = value;
                          });
                          await Settings.save();
                        },
                        title: const Text("Allow Haptics")),
                  ),
                Card(
                  child: ListTile(
                    title: const Text('Connection status'),
                    subtitleTextStyle: TextStyle(
                      color: SocketIOController.instance.connected ? Colors.green : Colors.red,
                    ),
                    subtitle: Text(SocketIOController.instance.connected ? 'Connected' : 'Disconnected'),
                    trailing:
                        IconButton.filled(isSelected: false, onPressed: () => {SocketIOController.instance.reconnect()}, icon: Icon(Icons.refresh)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => {
                    showAboutDialog(
                        context: context,
                        applicationName: 'Knoknok',
                        applicationVersion: '1.1.0',
                        applicationIcon: const Icon(Icons.waving_hand),
                        children: [
                          const Text('Knoknok is a simple app to send pings to those you care about.'),
                          const SizedBox(height: 16),
                          const Text('Made with ❤️ by Lyra S.R. Mikkelsen.'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                              onPressed: () async {
                                final url = Uri.parse("https://github.com/SorceressLyra/knoknokFlutter");
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                              icon: const Icon(Icons.source),
                              label: const Text('Source Code'))
                        ]),
                  },
                  icon: Icon(Icons.info),
                  label: const Text('About'),
                ),
                const SizedBox(height: 16),
                if (Platform.isWindows)
                  ElevatedButton.icon(
                    onPressed: () => {
                      windowManager.close(),
                    },
                    label: const Text('Close Knoknok'),
                    icon: Icon(Icons.exit_to_app),
                  )
              ],
            ),
          );
        });
  }
}
