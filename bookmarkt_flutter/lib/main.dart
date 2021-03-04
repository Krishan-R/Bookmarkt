import 'package:bookmarkt_flutter/Widgets/addBookAlert.dart';
import 'package:bookmarkt_flutter/Widgets/addBookData.dart';
import 'package:bookmarkt_flutter/allBooks.dart';
import 'package:bookmarkt_flutter/bookView.dart';
import 'package:bookmarkt_flutter/bookshelf.dart';
import 'package:bookmarkt_flutter/homepage.dart';
import 'package:bookmarkt_flutter/library.dart';
import 'package:bookmarkt_flutter/loading.dart';
import 'package:bookmarkt_flutter/findServer.dart';
import 'package:bookmarkt_flutter/login.dart';
import 'package:bookmarkt_flutter/readingSession.dart';
import 'package:bookmarkt_flutter/signUp.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => findServer(),
    '/findServer': (context) => findServer(),
    '/login': (context) => Login(),
    '/signUp': (context) => SignUp(),
    '/home': (context) => homepage(),
    '/library': (context) => Library(),
    '/bookshelf': (context) => Bookshelf(),
    '/allBooks': (context) => AllBooks(),
    '/book': (context) => bookView(),
    '/readingSession': (context) => readingSession(),
    '/addBook': (context) => addBook()
  },
));




