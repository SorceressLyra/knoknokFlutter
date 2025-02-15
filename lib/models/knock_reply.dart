
class KnockReply {
  String target = "";
  String sender = "";
  String message = "";
  
  KnockReply(this.target, this.sender, this.message);

  static fromJson(data) {
    return KnockReply(data['target'], data['sender'], data['message']);
  }
}
