import 'package:bookmarkt_flutter/Models/API%20requests.dart';
import 'package:bookmarkt_flutter/Models/navigatorArguments.dart';
import 'package:bookmarkt_flutter/Models/user.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  bool passwordVisible = true;
  bool incorrectCredentials = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Enter Credentials"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(hintText: "Username"),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Username cannot be empty";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Password cannot be empty";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.lock,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: passwordVisible,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Visibility(
                    child: Text(
                      "Incorrect Credentials",
                      style: TextStyle(color: Colors.red),
                    ),
                    visible: incorrectCredentials,
                  ),
                ),
                FlatButton(
                  child: Text("Create New Account"),
                  onPressed: () {
                    Navigator.pushNamed(context, '/signUp',
                        arguments: NavigatorArguments(args.user, args.url));
                  },
                ),
                FlatButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      User u = await loginToServer(args.url,
                          usernameController.text, passwordController.text);

                      if (u != null) {
                        incorrectCredentials = false;
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/home", (route) => false,
                            arguments: NavigatorArguments(u, args.url));
                      } else {
                        setState(() {
                          incorrectCredentials = true;
                        });
                      }
                    }
                  },
                  child: Text("Login"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
