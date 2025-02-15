import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:knoknok_mobile/models/knock.dart';
import 'package:intl/intl.dart';
import 'package:knoknok_mobile/models/settings_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Knock> knocks = [
    Knock("Lyra", "Lyra loves you!", DateTime.now().millisecondsSinceEpoch),
    Knock("Prism", "Prism misses you", DateTime.now().millisecondsSinceEpoch),
    Knock("Oort", "Meow", DateTime.now().millisecondsSinceEpoch),
  ];

  bool usePredefinedMessage = true;

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
                    title: Text(knock.message,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "From ${knock.username} at ${DateFormat('HH:mm E').format(knock.time)}"),
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
                        setState(() {
                          knocks.remove(knock);
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
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text("Reply to ${knock.username}?"),
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
                  onPressed: () => Navigator.pop(context),
                  child: Text("Send"),
                ),
              ],
            );
          });
        });
  }
}
