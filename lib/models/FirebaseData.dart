class FirebaseData {
  String email;
  String bearer;
  String wkid;
  String kbid;
  String botId;
  String botBehavior;

  FirebaseData(
      {required this.email,
      required this.bearer,
      required this.wkid,
      required this.kbid,
      required this.botId,
      required this.botBehavior});

  Map<String, dynamic> toMap() {
    return {"email": email, "bearer": bearer, "wkid": wkid, "kbid": kbid};
  }

  factory FirebaseData.fromMap(Map<String, dynamic> map) {
    return FirebaseData(
        email: map['email'],
        bearer: map['bearer'],
        wkid: map['wkid'],
        kbid: map['kbid'],
        botId: map['botid'],
        botBehavior: map['botbehavior']);
  }
}
