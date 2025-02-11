
import 'package:flutter/material.dart';
import 'package:knoknok_mobile/models/settings_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ConnectionHandler {
  static IO.Socket? socket;
  static final ValueNotifier<bool> connectionStatus = ValueNotifier<bool>(false);

  static void initializeSocket() {
    socket = IO.io(Settings.instance.serverUrl, <String, dynamic>{
      'transports': ['websocket'],
    });

    socket!.onConnect((_) {
      connectionStatus.value = true;
    });

    socket!.onDisconnect((_) {
      connectionStatus.value = false;
    });

    socket!.onConnectError((err) {
      connectionStatus.value = false;
    });

    socket!.onError((err) {
      connectionStatus.value = false;
    });

    // Attempt to connects
    socket!.connect();
    }

  static void disconnect() {
    socket?.dispose();
    socket = null;
    connectionStatus.value = false;
  }

  static void reconnect() {
    if (socket != null) {
      socket!.dispose();
      socket = null;

      initializeSocket();
    }
  }

  static void emit(String event, dynamic data) {
    if (socket != null && socket!.connected) {
      socket!.emit(event, data);
    }
  }

  static void on(String event, Function(dynamic) callback) {
    socket?.on(event, callback);
  }

  static bool isConnected() {
    return socket?.connected ?? false;
  }
}