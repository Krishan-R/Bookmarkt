import 'package:bookmarkt_flutter/Models/API%20requests.dart';
import 'package:bookmarkt_flutter/Models/navigatorArguments.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController usernameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  bool passwordVisible = true;
  bool confirmPasswordVisible = true;

  bool usernameConflict = false;
  bool emailConflict = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Sign Up"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text("Register New Account",
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(hintText: "Username"),
                      validator: (value) {
                        if (value.isEmpty) return "Username cannot be empty";
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(hintText: "Email"),
                      validator: (value) {
                        if (value.isEmpty) return "Email cannot be empty";

                        bool emailValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value);
                        if (!emailValid) return "Email not correct format";

                        return null;
                      },
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                          hintText: "Password",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.remove_red_eye,
                                color: Theme.of(context).primaryColorDark),
                            onPressed: () {
                              setState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                          )),
                      validator: (value) {
                        if (value.isEmpty) return "Password cannot be empty";
                        return null;
                      },
                      obscureText: passwordVisible,
                    ),
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.remove_red_eye,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            setState(() {
                              confirmPasswordVisible = !confirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value.isEmpty)
                          return "Confirm Password cannot be empty";
                        if (passwordController.text !=
                            confirmPasswordController.text)
                          return "Passwords need to match";
                        return null;
                      },
                      obscureText: confirmPasswordVisible,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Visibility(
                        child: Text("Username already exists",
                            style: TextStyle(color: Colors.red)),
                        visible: usernameConflict,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Visibility(
                        child: Text(
                            "There is already an account associated with this email",
                            style: TextStyle(color: Colors.red)),
                        visible: emailConflict,
                      ),
                    ),
                    FlatButton(
                        child: Text("Sign Up", style: TextStyle(color: Colors.white)),
                        color: Theme.of(context).primaryColor,
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            String result = await signUp(
                                args.url,
                                usernameController.text,
                                passwordController.text,
                                emailController.text);

                            if (result == "success") {
                              usernameConflict = false;
                              emailConflict = false;
                              Fluttertoast.showToast(
                                  msg: "Successfully created account");
                              Navigator.pop(context);
                            } else if (result == "usernameConflict") {
                              setState(() {
                                usernameConflict = true;
                              });
                            } else if (result == "emailConflict") {
                              setState(() {
                                emailConflict = true;
                              });
                            } else if (result == "SocketException") {
                              Fluttertoast.showToast(
                                  msg: "Error connecting to server");
                            }
                          }
                        })
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
