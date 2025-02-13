import 'package:knoknok_mobile/models/settings_model.dart';

class Knock {
  String username = "";
  String message = "";
  int id = -1;
  DateTime time = DateTime(0);
  
  Knock(this.username, this.message, this.id){
    time = DateTime.now();
  }

  Knock.fromSettings(Settings settingsIntance){
    username = settingsIntance.username;
    message = settingsIntance.customMessage;
    id = DateTime.now().millisecondsSinceEpoch;
    time = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'message': message,
      'id': id,
    };
  }
}
