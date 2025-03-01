import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:knoknok/controllers/connection_controller.dart';
import 'package:knoknok/firebase/firebase_handler.dart';
import 'package:knoknok/controllers/knock_controller.dart';
import 'package:knoknok/main_app.dart';
import 'package:knoknok/models/knock.dart';
import 'package:knoknok/models/knock_reply.dart';
import 'package:knoknok/models/settings_model.dart';
import 'package:knoknok/android_notifier.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  //Initialize
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (Platform.isAndroid) {
    FirebaseHandler().init();
    NotificationService.initialize();
  }

  await KnockManager.instance.initialize();

  // Load settings
  await Settings.initialize();

  // Connect to server
  ConnectionHandler.initializeSocket();

  // Listen for connection status changes
  ConnectionHandler.connectionStatus.addListener(() {
    if (ConnectionHandler.connectionStatus.value == true) {
      ConnectionHandler.on("knock_broadcast", KnockManager.instance.handleKnock);
      ConnectionHandler.on("knock_reply_broadcast", KnockManager.instance.handleKnockReply);
    }

    if (ConnectionHandler.connectionStatus.value == false) {
      ConnectionHandler.off("knock_broadcast", KnockManager.instance.handleKnock);
      ConnectionHandler.off("knock_reply_broadcast", KnockManager.instance.handleKnockReply);
    }
  });

  await initializeWindows();
  runApp(const MainApp());
}

Future<void> initializeWindows() async {
  if (!Platform.isWindows) {
    return;
  }

  doWhenWindowReady(() {
    const initialSize = Size(500, 800);
    appWindow.minSize = initialSize;
    appWindow.maxSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.bottomRight;
    appWindow.title = "Knoknok";
  });

  await windowManager.ensureInitialized();

  await localNotifier.setup(
    appName: 'Knoknok',
    // The parameter shortcutPolicy only works on Windows
    shortcutPolicy: ShortcutPolicy.ignore,
  );

  initSystemTray();
}

Future<void> initSystemTray() async {
  final SystemTray systemTray = SystemTray();

  // We first init the systray menu and then add the menu entries
  await systemTray.initSystemTray(iconPath: 'lib/assets/waving_hand.ico');
  systemTray.setTitle("Knoknok");
  systemTray.setToolTip("Knoknok");

  // handle system tray event
  systemTray.registerSystemTrayEventHandler((eventName) {
    debugPrint("eventName: $eventName");
    if (eventName == kSystemTrayEventClick) {
      windowManager.show();
      windowManager.focus();
    }
  });
}
