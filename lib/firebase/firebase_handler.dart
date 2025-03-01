import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:knoknok/firebase_options.dart';
import 'package:knoknok/android_notifier.dart';
import 'package:knoknok/controllers/knock_controller.dart';
import 'package:knoknok/models/knock.dart';
import 'package:knoknok/models/settings_model.dart';

class FirebaseHandler {
  init() async {
    await Firebase.initializeApp(
        //options: DefaultFirebaseOptions.currentPlatform,
        );
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
    await FirebaseMessaging.instance.subscribeToTopic("knock_reply");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  final data = jsonDecode(message.data.values.first);

  String topic = message.from!.split("/").last;

  switch (topic) {
    case "knock":
      knockNotif(data);
      break;
    case "knock_reply":
      knockReplyNotif(data);
      break;
  }
}

@pragma('vm:entry-point')
void knockReplyNotif(data) async {

  //Ignore if the knock is not for me
  final username = await Settings.getUsername();
  if (data["target"] != username) {
    return;
  }

  NotificationService.initialize();
  NotificationService.showNotification(
    id: DateTime.now().millisecondsSinceEpoch % (1 << 31),
    title: '${data["sender"]} got your knock',
    body: data["message"],
    notificationDetails: AndroidNotificationDetails(
      "knockReplyChannel",
      "Knock Reply Notification",
      channelDescription: "Knock knock channel",
      importance: Importance.high,
      priority: Priority.high,
    ),
  );
}

@pragma('vm:entry-point')
void knockNotif(data) async {
  //Ignore if the knock is from the same user
  final username = await Settings.getUsername();
  if (data["username"] == username) {
    return;
  }

  NotificationService.initialize();

  KnockManager.instance.initialize();
  KnockManager.instance.addKnock(Knock.fromJson(data));

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
    ),
  );
}
