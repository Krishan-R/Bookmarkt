import 'dart:ui';

import 'package:bookmarkt_flutter/Models/API%20requests.dart';
import 'package:bookmarkt_flutter/Models/navigatorArguments.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class findServer extends StatefulWidget {
  @override
  _findServerState createState() => _findServerState();
}

class _findServerState extends State<findServer> {
  String url;
  bool serverURLError = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: new Text("Find Bookmarkt Server"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "You need a Bookmarkt server to connect to, please enter its IP address below",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FutureBuilder(
                            future: getSavedURL(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                url = snapshot.data;

                                return TextFormField(
                                  initialValue: snapshot.data,
                                  validator: (value) {
                                    if (url.isEmpty) {
                                      return "Server URL must not be empty";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    url = value;
                                  },
                                  decoration: InputDecoration(
                                      hintText: "Enter Server URL"),
                                  textAlign: TextAlign.center,
                                );
                              } else if (snapshot.hasError) {
                                return Text(snapshot.error);
                              }
                              return Text("loading");
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Visibility(
                              child: Text(
                                "Server not found",
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              visible: serverURLError,
                            ),
                          ),
                          FlatButton(
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                bool serverFound = await connectToServer(url);

                                if (serverFound) {
                                  setState(() {
                                    serverURLError = false;
                                  });

                                  saveURL(url);
                                  Navigator.pushNamed(context, '/login',
                                      arguments: NavigatorArguments(null, url));
                                } else {
                                  setState(() {
                                    serverURLError = true;
                                  });
                                }
                              }
                            },
                            child: Text("Enter"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<String> getSavedURL() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String savedURL = prefs.getString("url") ?? "";

  return savedURL;
}

saveURL(String url) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("url", url);
}
