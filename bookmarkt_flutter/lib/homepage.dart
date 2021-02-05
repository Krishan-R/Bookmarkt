import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/material.dart';

class homepage extends StatefulWidget {
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {

  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute
        .of(context)
        .settings
        .arguments;
    return Scaffold(
      appBar: AppBar(),
      body: Text(args.user.username),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text("Drawer Header"),
              decoration: BoxDecoration(
                color: Colors.blue
              ),
            ),
            ListTile(
              title: Text("Logout"),
              onTap:() {
                logOutAlertDialog(context);

                // Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
              },
            )
          ],
        ),
      ),
    );
  }
}

logOutAlertDialog(BuildContext context) {

  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed:  () {Navigator.of(context).pop();},
  );
  Widget continueButton = FlatButton(
    child: Text("Log Out"),
    onPressed:  () {Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);},
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
