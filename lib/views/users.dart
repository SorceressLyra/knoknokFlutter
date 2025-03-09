import 'dart:math';

import 'package:flutter/material.dart';
import 'package:knoknok/controllers/socket_io_controller.dart';
import 'package:knoknok/models/connection_user.dart';
import 'package:knoknok/widgets/bottom_sheet.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  List<String> emptyMessages = [];
  String selectedMessageType = "default";

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
              builder: (context) => KnoknokBottomSheet(
                    builder: (context) => StatefulBuilder(
                      builder: (context, setState) => Column(
                        children: [
                          FilledButton(onPressed: () => {}, child: Text("Send Message")),
                        ],
                      ),
                    ),
                  ))
        },
      ),
      title: Text(user.username),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              if (!SocketIOController.hasUsers)
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
              for (var user in SocketIOController.getConnectedUsers) userCard(user),
            ],
          ),
        )
      ],
    );
  }
}
