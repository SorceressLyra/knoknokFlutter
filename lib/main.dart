import 'package:flutter/material.dart';
import 'package:knoknok_mobile/connection_handler.dart';
import 'package:knoknok_mobile/firebase_handler.dart';
import 'package:knoknok_mobile/main_app.dart';
import 'package:knoknok_mobile/models/settings_model.dart';
import 'package:knoknok_mobile/notifier.dart';

void main() async {

  //Initialize
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  FirebaseHandler().init();

  // Load sttings
  await Settings.initialize();

  // Connect to server
  ConnectionHandler.initializeSocket();

  // Initialize notifications
  NotificationService.initialize();



  debugPrint("${DateTime.now().toString()} - App started");

  runApp(const MainApp());
}
