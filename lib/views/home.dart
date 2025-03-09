import 'dart:math';

import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:knoknok/controllers/socket_io_controller.dart';
import 'package:knoknok/controllers/knock_controller.dart';
import 'package:knoknok/models/knock.dart';
import 'package:intl/intl.dart';
import 'package:knoknok/models/settings_model.dart';
import 'package:knoknok/widgets/bottom_sheet.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool usePredefinedMessage = true;
  List<String> emptyMessages = [];

  bool useDefaultMessage = false;

  @override
  void initState() {
    super.initState();

    emptyMessages = [
      "No knocks? Go bother someone!",
      "Fun Knock Fact: You can't knock on a door that doesn't exist",
      "Knock knock. Who's there? Nobody!",
      "You'd need no fingers to count the knocks you've got",
      "You're as popular as a doorbell in a ghost town",
      "Despite what you may think, you're not a door",
      "It might seem as if knocks aren't real, but they are",
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: KnockController.instance,
        builder: (context, _) {
          return Center(
              child: ListView(
            children: [
              if (!KnockController.instance.hasKnocks)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          emptyMessages[Random().nextInt(emptyMessages.length)],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),
              for (var knock in KnockController.instance.knocks)
                Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        ListTile(
                          leading: knockIcon(knock.message),
                          trailing: IconButton(
                              onPressed: () => {
                                    setState(() {
                                      KnockController.instance.removeKnock(knock);
                                    }),
                                    () async {
                                      if (Settings.instance.allowHaptics && await Haptics.canVibrate()) {
                                        await Haptics.vibrate(HapticsType.selection);
                                      }
                                    }
                                  },
                              icon: Icon(Icons.close)),
                          title: Text(knock.message, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("From ${knock.sender} at ${DateFormat('HH:mm E').format(knock.time)}"),
                        ),
                        SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            flex: 2,
                            child: FilledButton.icon(
                              onPressed: () => {
                                replyDialog(context, knock),
                              },
                              icon: Icon(Icons.reply),
                              label: Text("Reply"),
                            ),
                          ),
                          SizedBox(width: 20),
                          IconButton.filled(
                            isSelected: false,
                            onPressed: () => {
                              SocketIOController.instance.emit(
                                  "knock_send",
                                  Knock(
                                    sender: Settings.instance.username,
                                    receiver: knock.sender,
                                    isReply: true,
                                    message: "Gotcha Knock!",
                                  )),
                              setState(() {
                                KnockController.instance.removeKnock(knock);
                              }),
                              () async {
                                if (Settings.instance.allowHaptics && await Haptics.canVibrate()) {
                                  await Haptics.vibrate(HapticsType.selection);
                                }
                              }
                            },
                            icon: Icon(Icons.quickreply),
                          ),
                        ])
                      ],
                    ))
            ],
          ));
        });
  }

  knockIcon(String message) {
    message = message.toLowerCase();

    switch (message) {
      case String msg when msg.contains("miss"):
        return Icon(Icons.heart_broken);
      case String msg when msg.contains("love"):
        return Icon(Icons.favorite);
      case String msg when msg.contains("meow"):
      case String msg when msg.contains("cat"):
      case String msg when msg.contains("kitty"):
        return Icon(Icons.pets);
      default:
        return Icon(Icons.waving_hand);
    }
  }

  Future<dynamic> replyDialog(BuildContext context, Knock knock) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => KnoknokBottomSheet(
              title: "Reply to ${knock.sender}",
              builder: (context) => StatefulBuilder(
                builder: (context, setState) => Column(
                  children: [
                    TextField(
                      enabled: !useDefaultMessage,
                      decoration: InputDecoration(
                        labelText: !useDefaultMessage ? "Message" : Settings.instance.parsedMessage,
                        hintText: "Message to include with knock!",
                      ),
                    ),
                    Row(
                      children: [
                        Text("Use default message"),
                        Spacer(),
                        Switch(
                            value: useDefaultMessage,
                            onChanged: (value) => {
                                  setState(() {
                                    useDefaultMessage = value;
                                  })
                                }),
                      ],
                    ),
                    FilledButton.icon(
                      onPressed: () => {},
                      label: Text("Send Knock"),
                      icon: Icon(Icons.waving_hand),
                    ),
                  ],
                ),
              ),
            ));
  }
}
