import 'dart:io';

import 'package:flutter/material.dart';
import 'package:knoknok/models/connection_user.dart';
import 'package:knoknok/models/settings_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketIOController {
  static io.Socket? _socket;
  static final Map<String, Function(dynamic)> _listeners = {};
  static final ValueNotifier<bool> connectionStatus = ValueNotifier<bool>(false);
  static final List<ConnectionUser> _connectedUsers = [];

  /// Get all connected users except the current user
  static List<ConnectionUser> get getConnectedUsers {
    return _connectedUsers
      .where((user) => user.username != Settings.instance.username)
      .toList();
  }

  /// Get a specific user by username
  static bool get hasUsers {
    return _connectedUsers.where((user) => user.username != Settings.instance.username).isNotEmpty;
  }

  static void initializeSocket() {
    _socket = io.io(Settings.instance.serverUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'],
    });

    _socket!.onConnect((_) {
      connectionStatus.value = true;

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
    });

    _socket!.onDisconnect((_) {
      connectionStatus.value = false;
      _connectedUsers.clear();
    });

    _socket!.onConnectError((err) {
      connectionStatus.value = false;
    });

    _socket!.onError((err) {
      connectionStatus.value = false;
    });

    // Attempt to connects
    _socket!.connect();
  }

  static void disconnect() {
    _socket?.dispose();
    _socket = null;
    _listeners.clear();
    connectionStatus.value = false;
    _connectedUsers.clear();
  }

  static void reconnect() {
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

  static void emit(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(event, data);
    }
  }

  static void addListener(String event, Function(dynamic) callback) {
    _listeners[event] = callback;
    _socket!.on(event, callback);
  }

  static void removeListener(String event) {
    _listeners.remove(event);
    _socket!.off(event);
  }
}
