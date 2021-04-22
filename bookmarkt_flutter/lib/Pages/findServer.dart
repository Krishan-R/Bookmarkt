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
          title: new Text("Find Server"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
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
                        decoration:
                            InputDecoration(hintText: "Enter Server URL"),
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
                Image.network("https://www.themoviedb.org/t/p/w600_and_h900_bestv2/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg")
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
