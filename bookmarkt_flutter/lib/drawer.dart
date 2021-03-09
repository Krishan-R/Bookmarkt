import 'dart:io';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class myDrawer extends StatelessWidget {
  myDrawer(this.args);

  final NavigatorArguments args;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  args.user.username,
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  args.user.email,
                  style: TextStyle(fontSize: 15, color: Colors.white),
                )
              ],
            ),
            decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                    image: AssetImage("lib/Assets/drawerImg.jpg"),
                    fit: BoxFit.cover)),
          ),
          ListTile(
            title: Text("Dashboard"),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/home", (route) => false,
                  arguments: NavigatorArguments(args.user, args.url));
            },
          ),
          ListTile(
            title: Text("Library"),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/library", (route) => false,
                  arguments: NavigatorArguments(args.user, args.url));
            },
          ),
          ListTile(
            title: Text("Books"),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/allBooks", (route) => false,
                  arguments: NavigatorArguments(args.user, args.url));
            },
          ),
          Divider(
            thickness: 2,
            indent: 15,
            endIndent: 15,
          ),
          ListTile(
            title: Text("Logout"),
            onTap: () {
              logOutAlertDialog(context);
            },
          )
        ],
      ),
    );
  }
}

logOutAlertDialog(BuildContext context) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = FlatButton(
    child: Text("Log Out"),
    onPressed: () async {

      final prefs = await SharedPreferences.getInstance();

      prefs.setString("user", "");

      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Log Out"),
    content: Text("Are you sure you want to log out?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
