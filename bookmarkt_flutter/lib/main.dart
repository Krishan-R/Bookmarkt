import 'package:bookmarkt_flutter/homepage.dart';
import 'package:bookmarkt_flutter/loading.dart';
import 'package:bookmarkt_flutter/findServer.dart';
import 'package:bookmarkt_flutter/login.dart';
import 'package:bookmarkt_flutter/signUp.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => findServer(),
    '/findServer': (context) => findServer(),
    '/login': (context) => Login(),
    '/signUp': (context) => SignUp(),
    '/home': (context) => homepage()
  },
));

