import 'package:dynamic_system_colors/dynamic_system_colors.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:knoknok/connection_handler.dart';
import 'package:knoknok/home.dart';
import 'package:knoknok/models/knock.dart';
import 'package:knoknok/models/settings_model.dart';
import 'package:knoknok/settings.dart';
import 'dart:io';

import 'package:window_manager/window_manager.dart';

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
    super.initState();
    ConnectionHandler.connectionStatus.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    ConnectionHandler.connectionStatus.removeListener(() {
      setState(() {});
    });
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          final ColorScheme? currentScheme = MediaQuery.of(context).platformBrightness == Brightness.light
          ? lightDynamic
          : darkDynamic;
      
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: currentScheme
        ),
        home: Scaffold(
            appBar: AppBar(
              title: Text(_currentPage == 0 ? 'Home' : 'Settings'),
              actions: [
                if (Platform.isWindows)
                  IconButton(
                    tooltip: "Close to Tray",
                    onPressed: () {
                      windowManager.hide();
                    },
                    icon: const Icon(Icons.minimize),
                  ),
              ],
            ),
            body: PageView(
              controller: _controller,
              onPageChanged: (value) => setState(() {
                _currentPage = value;
              }),
              children: [
                Center(child: HomeView()),
                Center(child: SettingsView()),
              ],
            ),
            floatingActionButton: FloatingActionButton.large(
              onPressed: ConnectionHandler.connectionStatus.value
                  ? () async {
                      ConnectionHandler.emit(
                          "knock", Knock.fromSettings(Settings.instance));
                      if (Settings.instance.allowHaptics &&
                          await Haptics.canVibrate()) {
                        await Haptics.vibrate(HapticsType.rigid);
                      }
                    }
                  : null,
              backgroundColor: ConnectionHandler.connectionStatus.value
                  ? null
                  : currentScheme?.surfaceContainerHigh,
              child: Icon(ConnectionHandler.connectionStatus.value
                  ? Icons.waving_hand
                  : Icons.cloud_off),
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
