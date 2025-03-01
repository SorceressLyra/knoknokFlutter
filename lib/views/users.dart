import 'package:flutter/material.dart';
import 'package:knoknok/controllers/connection_controller.dart';
import 'package:knoknok/models/connection_user.dart';
import 'package:knoknok/models/knock.dart';
import 'package:knoknok/models/settings_model.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  Widget userCard(ConnectionUser user) {
    return Card(
      child: ListTile(
        leading: Icon(user.isOnMobile ? Icons.phone_android : Icons.phone_iphone),
        trailing: IconButton.filled(
          isSelected: false,
          icon: Icon(Icons.message),
          onPressed: () => {
            ConnectionController.emit("knock_send", Knock(
              sender: Settings.instance.username,
              isReply: false,
              message: "Knock knock!",
              receiver: user.username,
            )),
          },
        ),
        title: Text(user.username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              if (!ConnectionController.hasUsers)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Nobody online to knock.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              for (var user in ConnectionController.getConnectedUsers) userCard(user),
            ],
          ),
        )
      ],
    );
  }
}
