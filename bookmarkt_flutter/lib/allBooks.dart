import 'dart:convert';
import 'dart:io';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Widgets/addBookAlert.dart';
import 'package:bookmarkt_flutter/Widgets/bookListView.dart';
import 'package:bookmarkt_flutter/drawer.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class AllBooks extends StatefulWidget {
  @override
  _AllBooksState createState() => _AllBooksState();
}

class _AllBooksState extends State<AllBooks> {
  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Books"),
        ),
        drawer: myDrawer(args),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            addBookAlert(context, NavigatorArguments(args.user, args.url, redirect: "/allBooks"));
          },
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Book>>(
                future: getAllBookData(args),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Book> data = snapshot.data;
                    return bookListView(data, args);
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
  List<Book> bookList = new List<Book>();

  try {
    final response = await http.get("http://${args.url}:5000/users/${args.user.userID.toString()}/books/all");

    Iterable i = json.decode(response.body);

    // print(i);
    bookList = List<Book>.from(i.map((model) => Book.fromJson(model)));

    // for (var i = 0; i < bookList.length; i++) {
    //   print(bookList[i].ISBN.toString() +
    //       " " +
    //       bookList[i].thumbnail);
    // }

    return bookList;
  } on SocketException {
    print("Error connecting to server");
  }
}
