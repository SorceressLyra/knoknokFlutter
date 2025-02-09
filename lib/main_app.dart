import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dynamic_system_colors/dynamic_system_colors.dart';
import 'package:flutter/material.dart';
import 'package:knoknok_mobile/settings.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  final PageController _controller = PageController();

  int _currentPage = 0;

  @override
  void initState() {
    // Only after at least the action method is set, the notification events are delivered
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);

    // TODO: SOCKET IO TEST It works but needs proper implementations to be accessed where needed. Also to run in the background.
    IO.Socket socket = IO.io('http://192.168.50.14:3000',
    IO.OptionBuilder()
      .setTransports(['websocket']) // for Flutter or Dart VM
      .build());

    socket.onConnect((_) {
      print('connect');
      socket.emit('knock', "Hello");
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme:
                MediaQuery.of(context).platformBrightness == Brightness.light
                    ? lightDynamic
                    : darkDynamic,
          ),
          home: Scaffold(
              appBar: AppBar(
                title: Text(_currentPage == 0 ? 'Home' : 'Settings'),
              ),
              body: PageView(
                controller: _controller,
                onPageChanged: (value) => setState(() {
                  _currentPage = value;
                }),
                children: const [
                  Center(child: Text('Home')),
                  Center(child: SettingsView()),
                ],
              ),
              floatingActionButton: FloatingActionButton.large(
                onPressed: () => {
                  AwesomeNotifications()
                      .isNotificationAllowed()
                      .then((isAllowed) {
                    if (!isAllowed) {
                      // This is just a basic example. For real apps, you must show some
                      // friendly dialog box before call the request method.
                      // This is very important to not harm the user experience
                      AwesomeNotifications()
                          .requestPermissionToSendNotifications();
                    }
                  }),
                  AwesomeNotifications().createNotification(
                      content: NotificationContent(
                    id: 10,
                    channelKey: 'knock_channel',
                    actionType: ActionType.Default,
                    title: 'Knock knock!',
                    body: 'This is my first notification!',
                  ))
                },
                child: const Icon(Icons.notifications),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: BottomAppBar(
                shape: const CircularNotchedRectangle(),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton.filled(
                        isSelected: _currentPage == 0,
                        onPressed: () {
                          setState(() {
                            _controller.jumpToPage(0);
                          });
                        },
                        icon: const Icon(Icons.home),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton.filled(
                        isSelected: _currentPage == 1,
                        onPressed: () {
                          setState(() {
                            _controller.jumpToPage(1);
                          });
                        },
                        icon: const Icon(Icons.settings),
                      ),
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
    // Navigate into pages, avoiding to open the notification details page over another details page already opened
  }
}
