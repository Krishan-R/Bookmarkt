import 'dart:convert';
import 'dart:io';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Models/bookshelf.dart';
import 'package:bookmarkt_flutter/Pages/library.dart';
import 'package:bookmarkt_flutter/Widgets/addBookAlert.dart';
import 'package:bookmarkt_flutter/Widgets/bookListView.dart';
import 'package:bookmarkt_flutter/Models/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;

class BookshelfWidget extends StatefulWidget {
  @override
  _BookshelfWidgetState createState() => _BookshelfWidgetState();
}

class _BookshelfWidgetState extends State<BookshelfWidget> {
  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(args.bookshelfName),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (value) async {

                if (value == "Rename") {
                  renameDialog(context, args, args.bookshelfID, args.bookshelfName);
                } else if (value == "Delete") {

                  final response = await http.delete("http://${args.url}:5000/users/${args.user.userID.toString()}/bookshelf/${args.bookshelfID}/delete");
                  if (response.body == "deleted bookshelf") {
                    Navigator.pushReplacementNamed(context, "/library", arguments: args);
                  } else {
                    Fluttertoast.showToast(msg: "Error deleting Bookshelf");
                  }
                }

              },
              itemBuilder: (BuildContext context) {
                return {'Rename', 'Delete'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
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
              labelBackgroundColor: Colors.white,
              labelStyle: TextStyle(fontSize: 15),
              onTap: () async {
                print("scan ISBN pressed");

                String barcode;
                try {
                  barcode = await FlutterBarcodeScanner.scanBarcode(
                      "#ff6666", "Cancel", false, ScanMode.DEFAULT);
                } on PlatformException {
                  barcode = "-1";
                }

                if (barcode != "-1") {
                  List<Bookshelf> bookshelfList = await getBookshelfList(args);

                  final response = await http.post(
                      "http://${args.url}:5000/books/scrape?isbn=$barcode");

                  args.redirect = "/allBooks";

                  if (response.body == "Cannot be found") {
                    print("Cannot be found");
                    Book book = new Book();
                    book.ISBN = int.parse(barcode);

                    Navigator.pushNamed(context, '/addBook',
                        arguments: NavigatorArguments(args.user, args.url,
                            book: book,
                            bookshelfList: bookshelfList,
                            bookshelfID: args.bookshelfID,
                            bookshelfName: args.bookshelfName,
                            redirect: args.redirect));
                  } else {
                    Map i = json.decode(response.body);
                    Book book = Book.fromJsonBookData(i);
                    Navigator.pushNamed(context, '/addBook',
                        arguments: NavigatorArguments(args.user, args.url,
                            book: book,
                            bookshelfList: bookshelfList,
                            bookshelfID: args.bookshelfID,
                            bookshelfName: args.bookshelfName,
                            redirect: args.redirect));
                  }
                } else {
                  Fluttertoast.showToast(msg: "Error Scanning Barcode");
                }
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.space_bar),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              label: "Enter ISBN",
              labelBackgroundColor: Colors.white,
              labelStyle: TextStyle(fontSize: 15),
              onTap: () {
                addBookAlert(
                    context,
                    NavigatorArguments(args.user, args.url,
                        redirect: "/allBooks"));
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.search),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              label: "Search",
              labelBackgroundColor: Colors.white,
              labelStyle: TextStyle(fontSize: 15),
              onTap: () {
                args.redirect = "/allBooks";
                Navigator.pushNamed(context, "/searchBook", arguments: args);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Book>>(
                future: getBookshelfBookData(args),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Book> bookList = snapshot.data;
                    if (bookList.isEmpty)
                      return Text("This bookshelf is empty");
                    return bookListView(args: args, bookList: bookList);
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
  List<Book> bookList = [];

  try {
    final response = await http.get(
        "http://${args.url}:5000/users/${args.user.userID.toString()}/bookshelf/${args.bookshelfID}");

    if (response.body == "Bookshelf is empty") {
      return bookList;
    }

    Iterable i = json.decode(response.body)["books"];

    bookList = List<Book>.from(i.map((model) => Book.fromJson(model)));

    return bookList;
  } on SocketException {
    print("Error connecting to server");
  }
}
