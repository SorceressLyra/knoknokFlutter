class ConnectionUser{
  late final String name;
  late final String id;
  late final bool isMobile;

  String get username => name;
  String get userId => id;
  bool get isOnMobile => isMobile;

  ConnectionUser({required this.name, required this.id, required this.isMobile});

  factory ConnectionUser.fromJson(Map<String, dynamic> json) {
    return ConnectionUser(
      name: json['username'] as String,
      id: json['id'] as String,
      isMobile: json['isMobile'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': name,
      'id': id,
      'isMobile': isMobile,
    };
  }
}