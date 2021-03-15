import 'dart:convert';
import 'package:bookmarkt_flutter/Models/user.dart';
import 'package:bookmarkt_flutter/Models/navigatorArguments.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    redirect(context);
    return Scaffold();
  }
}

redirect(context) async {

  final prefs = await SharedPreferences.getInstance();

  if (prefs.getString("user") == null || prefs.getString("user") == "") {
    Navigator.pushReplacementNamed(context, "/findServer");
  }

  User user = User.fromJson(json.decode(prefs.getString("user")));

  String url = prefs.getString("url") ?? "";

  if (url != null || url != "") {
    Navigator.pushReplacementNamed(context, "/home", arguments: NavigatorArguments(user, url));
  } else {
    Navigator.pushReplacementNamed(context, "/findServer");
  }

}
