import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifier =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification settings
  static Future<void> initialize() async {
    await _notifier.initialize(
      const InitializationSettings(
        android:
            AndroidInitializationSettings("drawable/ic_launcher_foreground"),
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _notifier.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  /// Handle notification tap
  static Future<void> _onNotificationTap(NotificationResponse response) async {
    print("Active: Notification tapped: ${response.actionId}");
  }

  /// Show a basic notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    AndroidNotificationDetails? notificationDetails,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _notifier.show(
      id,
      title,
      body,
      NotificationDetails(android: notificationDetails ?? androidDetails),
    );
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Send knock reply
  if(response.actionId == 'knock_ack') {
    NotificationService.showNotification(
      id: 1,
      title: 'Knock Acknowledged',
      body: 'Who\'s there?',
    );
  }

}
