import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:knoknok_mobile/connection_handler.dart';
import 'package:knoknok_mobile/main_app.dart';
import 'package:knoknok_mobile/models/settings_model.dart';
import 'package:knoknok_mobile/notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  //Initialize 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load sttings
  await Settings.initialize();

  // Connect to server
  ConnectionHandler.initializeSocket();

  // Initialize notifications
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  await FirebaseMessaging.instance.subscribeToTopic("knock");
  
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {

    
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationService.initialize();

  runApp(const MainApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  NotificationService.initialize();

  final data = jsonDecode(message.data.values.first);

  NotificationService.showNotification(
    id: data["id"] % 10000,
    title: 'Knock from ${data["username"]}',
    body: data["message"],
    notificationDetails: AndroidNotificationDetails(
      "knockChannel",
      "Knock Notification",
      channelDescription: "Knock knock channel",
      importance: Importance.high,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('knock_ack', 'Gotcha',
            showsUserInterface: false, cancelNotification: true),
      ],
    ),
  );
}
