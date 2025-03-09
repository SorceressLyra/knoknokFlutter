import 'dart:math';

import 'package:flutter/material.dart';
import 'package:knoknok/controllers/socket_io_controller.dart';
import 'package:knoknok/models/connection_user.dart';
import 'package:knoknok/models/settings_model.dart';
import 'package:knoknok/widgets/bottom_sheet.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  List<String> emptyMessages = [];
  bool useDefaultMessage = true;

  @override
  void initState() {
    super.initState();

    emptyMessages = [
      "Where is everyone?",
      "Nobody's home!",
      "It's a ghost town in here",
      "The tumbleweeds are rolling through",
      "Nobody to talk to?",
      "Guess you gotta socialize with the tumbleweeds",
      "Go bother someone IRL, there's nobody here",
      "You're the only one in the room",
      "Lonely as a door without a house"
    ];
  }

  Widget userCard(ConnectionUser user) {
    return Card(
        child: ListTile(
      leading: Icon(user.isOnMobile ? Icons.phone_android : Icons.phone_iphone),
      trailing: IconButton.filled(
        isSelected: false,
        icon: Icon(Icons.message),
        onPressed: () => {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => KnoknokBottomSheet(
                    title: "Send knock to ${user.username}?",
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
                          FilledButton.icon(onPressed: () => {}, label: Text("Send Knock"), icon: Icon(Icons.waving_hand)),
                          SizedBox(height: 32.0),
                        ],
                      ),
                    ),
                  )),
        },
      ),
      title: Text(user.username),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: SocketIOController.instance,
        builder: (context, _) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (!SocketIOController.instance.hasUsers)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                emptyMessages[Random().nextInt(emptyMessages.length)],
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                    for (var user in SocketIOController.instance.getConnectedUsers) userCard(user),
                  ],
                ),
              )
            ],
          );
        });
  }
}
