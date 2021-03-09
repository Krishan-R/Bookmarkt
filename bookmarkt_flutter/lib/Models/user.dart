class User {
  String username;
  String email;
  int userID;

  User({
    this.userID,
    this.email,
    this.username
  });

  Map<String, dynamic> toJson() => {
    "username": username,
    "email": email,
    "userID": userID
  };

  User.fromJson(Map<String, dynamic> json)
    : username = json["username"],
      email = json["email"],
      userID = json["userID"];
}