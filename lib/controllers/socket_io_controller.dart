import 'dart:io';

import 'package:flutter/material.dart';
import 'package:knoknok/models/connection_user.dart';
import 'package:knoknok/models/settings_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketIOController with ChangeNotifier {
  static final _instance = SocketIOController();
  static SocketIOController get instance => _instance;

  io.Socket? _socket;
  bool connected = false;
  final Map<String, Function(dynamic)> _listeners = {};
  final List<ConnectionUser> _connectedUsers = [];

  /// Get all connected users except the current user
  List<ConnectionUser> get getConnectedUsers {
    return _connectedUsers.where((user) => user.username != Settings.instance.username).toList();
  }

  int get connectedUsersCount {
    return getConnectedUsers.length;
  }

  /// Get a specific user by username
  bool get hasUsers {
    return _connectedUsers.where((user) => user.username != Settings.instance.username).isNotEmpty;
  }

  void initializeSocket() {
    _socket = io.io(Settings.instance.serverUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'],
    });

    _socket!.onConnect((_) {
      connected = true;
      notifyListeners();

      emit("register", {
        "username": Settings.instance.username,
        "isMobile": Platform.isAndroid || Platform.isIOS,
        "id": _socket!.id,
      });
    });

    _socket!.on("connected_users", (data) {
      // Clear existing users first to avoid duplicates
      _connectedUsers.clear();
      // Parse data as a list of users
      final usersList = (data as List).cast<Map<String, dynamic>>();
      for (var userData in usersList) {
        _connectedUsers.add(ConnectionUser.fromJson(userData));
      }

      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      connected = false;
      _connectedUsers.clear();
    });

    _socket!.onConnectError((err) {
      connected = false;
    });

    _socket!.onError((err) {
      connected = false;
    });

    // Attempt to connects
    _socket!.connect();
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _listeners.clear();
    connected = false;
    _connectedUsers.clear();
  }

  void reconnect() {
    if (_socket != null) {
      _socket!.dispose();
      _socket = null;

      initializeSocket();

      //re-add listeners
      _listeners.forEach((event, callback) {
        _socket!.on(event, callback);
      });
    }
  }

  void emit(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(event, data);
    }
  }

  void addSocketListener(String event, Function(dynamic) callback) {
    _listeners[event] = callback;
    _socket!.on(event, callback);
  }

  void removeSocketListener(String event) {
    _listeners.remove(event);
    _socket!.off(event);
  }
}
