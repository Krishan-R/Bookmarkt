import 'dart:io';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/material.dart';

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
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Text(
                  args.user.email,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                )
              ],
            ),
            decoration: BoxDecoration(color: Colors.blue),
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
    onPressed: () {
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


