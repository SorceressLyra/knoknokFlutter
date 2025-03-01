import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:knoknok/controllers/connection_controller.dart';
import 'package:knoknok/firebase/firebase_handler.dart';
import 'package:knoknok/controllers/knock_controller.dart';
import 'package:knoknok/main_app.dart';
import 'package:knoknok/models/settings_model.dart';
import 'package:knoknok/android_notifier.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  //Initialize
  WidgetsFlutterBinding.ensureInitialized();

  // Load settings
  await Settings.initialize();
  
  // Initialize Firebase
  if (Platform.isAndroid) {
    FirebaseHandler().init();
    NotificationService.initialize();
  }

  await KnockController.instance.initialize();



  // Initialize connection controller
  ConnectionController.initializeSocket();
  ConnectionController.addListener("knock", KnockController.instance.handleKnock); //Global broadcasts
  ConnectionController.addListener("knock_${Settings.instance.username}", KnockController.instance.handleKnock); //Targeted

  await initializeWindows();
  runApp(const MainApp());
}

// Desktop specific code
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
