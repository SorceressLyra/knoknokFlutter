import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:knoknok_mobile/models/knock.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KnockManager extends ChangeNotifier {
  static final KnockManager _instance = KnockManager._internal();
  static KnockManager get instance => _instance;

  List<Knock> _knocks = [];
  List<Knock> get knocks => _knocks;

  KnockManager._internal();

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

  int get knockCount => _knocks.length;

  bool get hasKnocks => _knocks.isNotEmpty;
}
