class User{
  String username;
  String name;
  String lastName;
  String NFCID;
  String? faceID;

  User({
    required this.username,
    required this.name,
    required this.lastName,
    required this.NFCID,
    this.faceID,
  });
}