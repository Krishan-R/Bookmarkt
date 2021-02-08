import 'dart:convert';
import 'dart:io';

import 'package:bookmarkt_flutter/Models/book.dart';
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
    print(args.bookshelfID);
    return Scaffold(
      appBar: AppBar(title: Text(args.bookshelfName)),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: getBookshelfBookData(args),
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

    );
  }
}

Future<List<Book>> getBookshelfBookData(args) async {
  List<Book> bookList = new List<Book>();

  try {
    final response = await http.get("http://${args.url}:5000/users/${args.user.userID.toString()}/bookshelf/${args.bookshelfID}");

    Iterable i = json.decode(response.body);

    // print(i);
    bookList = List<Book>.from(i.map((model) => Book.fromJson(model)));

    for (var i = 0; i < bookList.length; i++) {
      print(bookList[i].ISBN.toString() +
          " " +
          bookList[i].bookshelfID.toString());
    }

    return bookList;
  } on SocketException {
    print("Error connecting to server");
  }
}
