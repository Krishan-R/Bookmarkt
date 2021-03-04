import 'dart:convert';
import 'dart:io';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Models/bookshelf.dart';
import 'package:bookmarkt_flutter/allBooks.dart';
import 'package:bookmarkt_flutter/drawer.dart';
import 'package:bookmarkt_flutter/library.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;

ListView bookListView(bookList, args) {
  //todo convert to stateful widget
  return ListView.builder(
    itemCount: bookList.length,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
        child: Container(
          height: 120,
          child: Card(
            child: InkWell(
              onTap: () async {

                List<Bookshelf> bookshelfList = await getBookshelfList(args);

                Navigator.pushNamed(context, '/book', arguments: NavigatorArguments(args.user, args.url, bookshelfList: bookshelfList, book: bookList[index]));
              },
              onLongPress: () {
                print(bookList[index].title);

                longPressBookDialog(context, args, bookList[index].bookInstanceID, bookList[index].title);

              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Hero(
                      tag: bookList[index].bookInstanceID,
                      child: Image.network(
                          "http://${args.url}:5000/getThumbnail?path=${bookList[index].thumbnail}"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookList[index].title,
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            bookList[index].author,
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "${bookList[index].currentPage.toString()}/${bookList[index].totalPages}",
                            style: TextStyle(color: Colors.grey),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

longPressBookDialog(BuildContext context, NavigatorArguments args, int bookInstanceID, String bookTitle) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Edit " + bookTitle),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlatButton(
            child: Text("Delete"),
            onPressed: () async {

              final response = await http.delete("http://${args.url}:5000/users/${args.user.userID.toString()}/books/delete?bookInstanceID=$bookInstanceID");

              if (response.body == "deleted book instance") {
                Navigator.pushReplacementNamed(context, "/allBooks", arguments: args);
              } else {
                print(response.body);
                Fluttertoast.showToast(msg: "Error deleting Book");
              }

            },
        ),
      ],
    ),
    actions: [
      cancelButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}