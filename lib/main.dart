import 'package:flutter/material.dart';
import 'package:knoknok_mobile/main_app.dart';
import 'package:knoknok_mobile/notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  NotificationService.initialize();

  runApp(const MainApp());
}

