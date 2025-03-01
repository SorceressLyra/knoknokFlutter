import 'package:knoknok/models/settings_model.dart';

class Knock {
  String sender = "";
  String message = "";
  String receiver = "";
  bool isReply = false;
  int id = -1;
  DateTime time = DateTime(0);

  Knock({
    this.sender = "",
    this.message = "",
    this.receiver = "",
    this.isReply = false,
  }){
    time = DateTime.now();
    id = DateTime.now().millisecondsSinceEpoch;
  }

  Knock.fromSettings(Settings settingsIntance) {
    sender = settingsIntance.username;
    receiver = "BROADCAST_ALL";
    isReply = false;
    message = settingsIntance.parsedMessage;
    id = DateTime.now().millisecondsSinceEpoch;
    time = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'receiver': receiver, // corrected 'reciever' to 'receiver'
      'isReply': isReply,
      'message': message,
      'id': id,
    };
  }

  static Knock fromJson(Map<String, dynamic> data) {
    final knock = Knock();
    knock.sender = data['sender'] ?? "";
    knock.receiver = data['receiver'] ?? "";
    knock.isReply = data['isReply'] ?? false;
    knock.message = data['message'] ?? "";
    knock.id = data['id'] ?? DateTime.now().millisecondsSinceEpoch;

    return knock;
  }
}
