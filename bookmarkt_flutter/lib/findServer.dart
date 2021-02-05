import 'dart:io';

import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class findServer extends StatefulWidget {
  @override
  _findServerState createState() => _findServerState();
}

class _findServerState extends State<findServer> {
  TextEditingController serverURLController = new TextEditingController();
  bool serverURLError = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text("Find Server"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: serverURLController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Server URL must not be empty";
                    }
                    return null;
                  },
                  decoration: InputDecoration(hintText: "Enter Server URL"),
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
                      bool serverFound =
                          await connectToServer(serverURLController.text);

                      if (serverFound) {
                        setState(() {
                          serverURLError = false;
                        });
                        Navigator.pushNamed(context, '/login',
                            arguments: NavigatorArguments(
                                null, serverURLController.text));
                      } else {
                        setState(() {
                          serverURLError = true;
                        });
                      }
                    }
                  },
                  child: Text("Enter"),
                )
              ],
            ),
          ),
        ));
  }
}

Future<bool> connectToServer(url) async {
  try {
    final response = await http.get("http://" + url + ":5000");
    if (response.body == "True") {
      print("Server found");
      return Future.value(true);
    }
  } on SocketException {
    print("server does not exist");
    return Future.value(false);
  }

  return Future.value(false);
}
