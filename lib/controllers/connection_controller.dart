import 'package:flutter/material.dart';
import 'package:knoknok/models/knock.dart';
import 'package:knoknok/models/settings_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ConnectionController {
  static io.Socket? socket;
  static final Map<String, Function(dynamic)> _listeners = {};
  static final ValueNotifier<bool> connectionStatus =
      ValueNotifier<bool>(false);

  

  static void initializeSocket() {
    socket = io.io(Settings.instance.serverUrl, <String, dynamic>{
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
    _listeners.clear();
    connectionStatus.value = false;
  }

  static void reconnect() {
    if (socket != null) {
      socket!.dispose();
      socket = null;

      initializeSocket();

      //re-add listeners
      _listeners.forEach((event, callback) {
        socket!.on(event, callback);
      });
    }
  }

  static void emit(String event, dynamic data) {
    if (socket != null && socket!.connected) {
      socket!.emit(event, data);
    }
  }

  static void addListener(String event, Function(dynamic) callback) {
    _listeners[event] = callback;
    socket!.on(event, callback);
  }

  static void removeListener(String event) {
    _listeners.remove(event);
    socket!.off(event);
  }

}
