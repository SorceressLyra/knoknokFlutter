import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:knoknok/android_notifier.dart';
import 'package:knoknok/models/knock.dart';
import 'package:knoknok/models/knock_reply.dart';
import 'package:knoknok/models/settings_model.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class KnockController extends ChangeNotifier {
  static final KnockController _instance = KnockController._internal();
  static KnockController get instance => _instance;

  List<Knock> _knocks = [];
  List<Knock> get knocks => _knocks;

  KnockController._internal();

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final String? knocksJson = prefs.getString('knocks');

    if (knocksJson != null) {
      final List<Knock> json = (jsonDecode(knocksJson) as List<dynamic>)
          .map((e) => Knock.fromJson(e))
          .toList()
          .cast<Knock>();

      _knocks = json;
      updateKnockInfo();
    }
  }

  final _knockStreamController = StreamController<List<Knock>>.broadcast();
  Stream<List<Knock>> get onKnocksChanged => _knockStreamController.stream;

  void addKnock(Knock knock) async {
    _knocks.insert(0, knock);
    await updateKnockInfo();
  }

  void removeKnock(Knock knock) async {
    _knocks.remove(knock);
    await updateKnockInfo();
  }

  Future<void> updateKnockInfo() async {
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('knocks', jsonEncode(_knocks));
  }

  void clearKnocks() async {
    _knocks.clear();
    await updateKnockInfo();
  }

  void handleKnock(data) {
  final knock = Knock.fromJson(data);

  knock.time = DateTime.now();
  if (knock.username == Settings.instance.username) {
    return;
  }

  KnockController.instance.addKnock(knock);
  if (Platform.isWindows) {
    LocalNotification notification = LocalNotification(
      title: "Knock from ${knock.username}",
      body: knock.message,
    );
    notification.onClick = () {
      windowManager.show();
      windowManager.focus();
    };
    notification.show();
  }
}

handleKnockReply(data) {
  final knockReply = KnockReply.fromJson(data);

  if (knockReply.target != Settings.instance.username) {
    return;
  }

  if (Platform.isAndroid) {
    NotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch % (1 << 31),
      title: '${knockReply.sender} got your knock',
      body: knockReply.message,
      notificationDetails: AndroidNotificationDetails(
        "knockReplyChannel",
        "Knock Reply Notification",
        channelDescription: "Knock knock channel",
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
  }

  if (Platform.isWindows) {
    LocalNotification notification = LocalNotification(
      title: "${knockReply.sender} got your knock",
      body: knockReply.message,
    );
    notification.onClick = () {
      windowManager.show();
      windowManager.focus();
    };
    notification.show();
  }
}

  int get knockCount => _knocks.length;

  bool get hasKnocks => _knocks.isNotEmpty;
}
