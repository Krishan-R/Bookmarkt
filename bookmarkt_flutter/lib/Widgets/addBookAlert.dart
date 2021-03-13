import 'dart:convert';
import 'dart:io';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Models/bookshelf.dart';
import 'package:bookmarkt_flutter/Widgets/addBookData.dart';
import 'package:bookmarkt_flutter/library.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

addBookAlert(BuildContext context, NavigatorArguments args) {
  final _formKey = GlobalKey<FormState>();

  TextEditingController bookISBNController = new TextEditingController();

  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  Widget continueButton = FlatButton(
    child: Text("Add"),
    onPressed: () async {
      if (_formKey.currentState.validate()) {
        try {
          List<Bookshelf> bookshelfList = await getBookshelfList(args);

          final response = await http.post(
              "http://${args.url}:5000/books/scrape?isbn=${bookISBNController.text}");

          if (response.body == "Cannot be found") {
            print("Cannot be found");
            Book book = new Book();
            book.ISBN = int.parse(bookISBNController.text);

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
        } on SocketException {
          print("error connecting to server");
        }
      }
    },
  );

  AlertDialog inputISBNWidget = AlertDialog(
    title: Text("Add new book"),
    content: Form(
      key: _formKey,
      child: TextFormField(
        controller: bookISBNController,
        decoration: InputDecoration(hintText: "Book ISBN"),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value.isEmpty) return "Book ISBN cannot be empty";
          return null;
        },
      ),
    ),
    actions: [cancelButton, continueButton],
  );

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return inputISBNWidget;
      });
}
