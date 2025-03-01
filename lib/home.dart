import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:knoknok/controllers/connection_controller.dart';
import 'package:knoknok/controllers/knock_controller.dart';
import 'package:knoknok/models/knock.dart';
import 'package:intl/intl.dart';
import 'package:knoknok/models/settings_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Knock> knocks = [];
  bool usePredefinedMessage = true;

  @override
  void initState() {
    super.initState();
    knocks = KnockController.instance.knocks;

    KnockController.instance.addListener(updateHomeState);
  }

  @override
  void dispose() {
    super.dispose();

    KnockController.instance.removeListener(updateHomeState);
  }

  void updateHomeState() {
    setState(() {
      knocks = KnockController.instance.knocks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ListView(
      children: [
        for (var knock in knocks)
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
                                if (Settings.instance.allowHaptics &&
                                    await Haptics.canVibrate()) {
                                  await Haptics.vibrate(HapticsType.selection);
                                }
                              }
                            },
                        icon: Icon(Icons.close)),
                    title: Text(knock.message,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "From ${knock.sender} at ${DateFormat('HH:mm E').format(knock.time)}"),
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
                        ConnectionController.emit("knock_send", Knock(
                            sender: Settings.instance.username,
                            receiver: knock.sender,
                            isReply: true,
                            message: "Gotcha Knock!",)),
                        setState(() {
                          KnockController.instance.removeKnock(knock);
                        }),
                        () async {
                          if (Settings.instance.allowHaptics &&
                              await Haptics.canVibrate()) {
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
    final TextEditingController messageController = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text("Reply to ${knock.sender}?"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  SwitchListTile(
                      value: usePredefinedMessage,
                      onChanged: (value) =>
                          setState(() => usePredefinedMessage = value),
                      title: Text("Use default message")),
                  if (!usePredefinedMessage)
                    TextField(
                      controller: messageController,
                      decoration:
                          InputDecoration(labelText: "Enter your message"),
                    ),
                ]),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => {
                    ConnectionController.emit("knock_reply", {
                      "target": knock.sender,
                      "sender": Settings.instance.username,
                      "message": usePredefinedMessage
                          ? Settings.instance.parsedMessage
                          : messageController.text
                    }),
                    Navigator.pop(context),
                    setState(() {
                      KnockController.instance.removeKnock(knock);
                    }),
                  },
                  child: Text("Send"),
                ),
              ],
            );
          });
        });
  }
}
