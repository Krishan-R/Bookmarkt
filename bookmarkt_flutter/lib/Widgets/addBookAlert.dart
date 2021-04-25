import 'dart:convert';
import 'dart:io';
import 'package:bookmarkt_flutter/Models/API%20requests.dart';
import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Models/bookshelf.dart';
import 'package:bookmarkt_flutter/Models/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

          if (response.statusCode == 404) {
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
