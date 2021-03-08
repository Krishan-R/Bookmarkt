import 'package:bookmarkt_flutter/drawer.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/material.dart';

class homepage extends StatefulWidget {
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Home"),),
        drawer: myDrawer(args),
        // body: Text("homepage"),
        body: Text("Home")
      ),
    );
  }
}

