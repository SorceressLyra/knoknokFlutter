import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:knoknok_mobile/main_app.dart';

void main() {



  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    'resource://drawable/ic_launcher_foreground',
    [
      NotificationChannel(
          channelGroupKey: 'knoknok_channel_group',
          channelKey: 'knock_channel',
          channelName: 'Knocks',
          channelDescription: 'Knocks are recieved here',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white)
    ],
    debug: true
  );

  runApp(const MainApp());
}
