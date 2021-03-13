import 'dart:convert';
import 'dart:io';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Widgets/addBookAlert.dart';
import 'package:bookmarkt_flutter/Widgets/bookListView.dart';
import 'package:bookmarkt_flutter/drawer.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:http/http.dart' as http;

class AllBooks extends StatefulWidget {
  @override
  _AllBooksState createState() => _AllBooksState();
}

class _AllBooksState extends State<AllBooks> {
  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;

    List<Book> bookList = List<Book>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Books"),
        ),
        drawer: myDrawer(args),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.remove,
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          overlayOpacity: 0,
          children: [
            SpeedDialChild(
              child: Icon(Icons.camera_alt_rounded),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              label: "Scan ISBN",
              labelStyle: TextStyle(fontSize: 15),
              onTap: () {
                print("scan ISBN pressed");
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.space_bar),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              label: "Enter ISBN",
              labelStyle: TextStyle(fontSize: 15),
              onTap: () {
                addBookAlert(context, NavigatorArguments(args.user, args.url, redirect: "/allBooks"));
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.search),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              label: "Search",
              labelStyle: TextStyle(fontSize: 15),
              onTap: () {
                Navigator.pushNamed(context, "/searchBook", arguments: args);
                print("search pressed");
              },
            ),

          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Book>>(
                future: getAllBookData(args),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Book> bookList = snapshot.data;

                    if (bookList.isEmpty) return Text("No books have been added to your account");
                    else return bookListView(args: args, bookList: bookList);
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Future<List<Book>> getAllBookData(args) async {
  List<Book> bookList = [];

  try {
    final response = await http.get("http://${args.url}:5000/users/${args.user.userID.toString()}/books/all");

    if (response.body == "No books") {
      return bookList;
    }

    Iterable i = json.decode(response.body);

    bookList = List<Book>.from(i.map((model) => Book.fromJson(model)));

    return bookList;
  } on SocketException {
    print("Error connecting to server");
  }
}
