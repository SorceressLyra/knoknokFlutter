import 'package:dynamic_system_colors/dynamic_system_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:knoknok_mobile/home.dart';
import 'package:knoknok_mobile/notifier.dart';
import 'package:knoknok_mobile/settings.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final PageController _controller = PageController();

  int _currentPage = 0;

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
                Center(child: HomeView()),
                Center(child: SettingsView()),
              ],
            ),
            floatingActionButton: FloatingActionButton.large(
              onPressed: () => {
                // Show notification
                NotificationService.showNotification(
                  id: 0,
                  title: 'Knock knock!',
                  body: 'Who\'s there?',
                  notificationDetails: AndroidNotificationDetails(
                    "knockChannel",
                    "Knock Channel",
                    channelDescription: "Knock knock channel",
                    importance: Importance.high,
                    priority: Priority.high,
                    actions: <AndroidNotificationAction>[
                      AndroidNotificationAction('knock_ack', 'Gotcha',
                          showsUserInterface: false, cancelNotification: true),
                    ],
                  ),
                )
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
                  Spacer(),
                ],
              ),
            )),
      );
    });
  }
}
