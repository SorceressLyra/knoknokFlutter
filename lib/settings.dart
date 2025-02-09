
import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget{
  const SettingsView({super.key});

  final bool _isConnected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 25,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Username',
            ),
          ),
        ),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Server URL',
          ),
        ),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Custom message',
          ),
        ),
        Text("Connection status: ${_isConnected ? 'Connected' : 'Disconnected'}"),
      ],
    );
  }
}