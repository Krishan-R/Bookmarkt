import 'package:bookmarkt_flutter/Pages/allBooks.dart';
import 'package:bookmarkt_flutter/Pages/bookshelf.dart';
import 'package:bookmarkt_flutter/Pages/homepage.dart';
import 'package:bookmarkt_flutter/Pages/library.dart';
import 'package:bookmarkt_flutter/Pages/loading.dart';
import 'package:bookmarkt_flutter/Pages/readingSessionHistory.dart';
import 'package:bookmarkt_flutter/Widgets/addBookData.dart';
import 'package:bookmarkt_flutter/Pages/bookView.dart';
import 'package:bookmarkt_flutter/Pages/findServer.dart';
import 'package:bookmarkt_flutter/Pages/login.dart';
import 'package:bookmarkt_flutter/Pages/readingSessions.dart';
import 'package:bookmarkt_flutter/Pages/searchBook.dart';
import 'package:bookmarkt_flutter/Pages/signUp.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => Loading(),
    '/findServer': (context) => findServer(),
    '/login': (context) => Login(),
    '/signUp': (context) => SignUp(),
    '/home': (context) => homepage(),
    '/library': (context) => Library(),
    '/bookshelf': (context) => BookshelfWidget(),
    '/allBooks': (context) => AllBooks(),
    '/book': (context) => bookView(),
    '/readingSession': (context) => readingSessionCoverPage(),
    '/addBook': (context) => addBook(),
    '/readingSessionHistory': (context) => readingSessionHistory(),
    '/allReadingSessions': (context) => allSessionHistory(),
    '/editReadingSession': (context) => editReadingSession(),
    '/searchBook' : (context) => SearchBook()
  },
));




