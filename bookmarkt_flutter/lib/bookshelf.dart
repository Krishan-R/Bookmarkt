import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Widgets/addBookAlert.dart';
import 'package:bookmarkt_flutter/Widgets/bookListView.dart';
import 'package:bookmarkt_flutter/allBooks.dart';
import 'package:bookmarkt_flutter/drawer.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class Bookshelf extends StatefulWidget {
  @override
  _BookshelfState createState() => _BookshelfState();
}

class _BookshelfState extends State<Bookshelf> {
  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(args.bookshelfName)),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            addBookAlert(context, NavigatorArguments(args.user, args.url, redirect: "/bookshelf"));
          },
        ),
          body: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Book>>(
                future: getBookshelfBookData(args),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Book> bookList = snapshot.data;
                    if (bookList.isEmpty) return Text("This bookshelf is empty");
                    return bookListView(bookList, args);
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

Future<List<Book>> getBookshelfBookData(args) async {
  List<Book> bookList = new List<Book>();


  try {
    final response = await http.get("http://${args.url}:5000/users/${args.user.userID.toString()}/bookshelf/${args.bookshelfID}");

    if (response.body == "Bookshelf is empty") {
      return bookList;
    }

    Iterable i = json.decode(response.body);

    // print(i);
    bookList = List<Book>.from(i.map((model) => Book.fromJson(model)));


    for (var i = 0; i < bookList.length; i++) {
      print(bookList[i].ISBN.toString() +
          " " +
          bookList[i].totalTimeRead.toString());
    }

    print(bookList[0].totalTimeRead.toString());



    return bookList;
  } on SocketException {
    print("Error connecting to server");
  }
}
