import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:knoknok/models/knock.dart';
import 'package:knoknok/models/settings_model.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class KnockController with ChangeNotifier {
  static final KnockController _instance = KnockController();
  static KnockController get instance => _instance;

  List<Knock> _knocks = [];
  List<Knock> get knocks => _knocks;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final String? knocksJson = prefs.getString('knocks');

    if (knocksJson != null) {
      final List<Knock> json = (jsonDecode(knocksJson) as List<dynamic>).map((e) => Knock.fromJson(e)).toList().cast<Knock>();

      _knocks = json;
      updateKnockInfo();
    }
  }

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

  void handleKnock(data) async {
    final knock = Knock.fromJson(data);

    knock.time = DateTime.now();
    if (knock.sender == Settings.instance.username) {
      return;
    }

    KnockController.instance.addKnock(knock);

    if (Platform.isWindows) {
      LocalNotification notification = LocalNotification(
        title: "Knock from ${knock.sender}",
        body: knock.message,
      );
      notification.onClick = () {
        windowManager.show();
        windowManager.focus();
      };
      notification.show();
    } else {
      if (Settings.instance.allowHaptics && await Haptics.canVibrate()) {
        Haptics.vibrate(HapticsType.rigid);
      }
    }
  }

  int get knockCount => _knocks.length;

  bool get hasKnocks => _knocks.isNotEmpty;
}
