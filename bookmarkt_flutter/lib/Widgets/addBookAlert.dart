import 'dart:convert';
import 'dart:io';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Models/bookshelf.dart';
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
            addBookDataAlert(context, args, book, bookshelfList);
          } else {
            Map i = json.decode(response.body);
            Book book = Book.fromJsonBookData(i);
            addBookDataAlert(context, args, book, bookshelfList);
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

addBookDataAlert(BuildContext context, NavigatorArguments args, Book book,
    List<Bookshelf> bookshelfList) {

  bool scraped = true;
  if (book.title == null) {
    scraped = false;
    book.totalPages = 0;
  } else scraped = true;

  final _formKey = GlobalKey<FormState>();
  TextEditingController currentPageController = new TextEditingController();

  bool completedCheckBox = false;

  int dropdownValue;
  if (bookshelfList.isEmpty) {
    Bookshelf emptyBookshelf =
        Bookshelf(bookshelfID: -1, name: "No Bookshelves");
    bookshelfList.add(emptyBookshelf);
    dropdownValue = -1;
  } else {
    dropdownValue = bookshelfList[0].bookshelfID;
  }

  for (var i = 0; i < bookshelfList.length; i++) {
    print(
        bookshelfList[i].name + " " + bookshelfList[i].bookshelfID.toString());
  }

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

          String bookshelfID = "";
          if (book.bookshelfID != null) bookshelfID = "&bookshelfID=${book.bookshelfID}";
          else bookshelfID = "";
          if (book.currentPage == null) book.currentPage = 1;
          String currentPage = "&currentPage=${book.currentPage}";
          String completed = "&completed=${completedCheckBox}";
          String rating = "&rating=${book.rating}";

          print("knaslfkansf " + book.bookshelfID.toString());


          final response = await http.post("http://${args.url}:5000/users/${args.user.userID.toString()}/books/add?isbn=${book.ISBN}${bookshelfID}${currentPage}${completed}${rating}");

          print(response.body);

          if (response.body == "added new BookInstance") {
            Navigator.popUntil(context, ModalRoute.withName(args.redirect));
          }




        } on SocketException {
          print("Error connecting to server");
        }

      }
    },
  );

  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Add new book"),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      enabled: !scraped,
                      initialValue: book.ISBN.toString(),
                      decoration: InputDecoration(hintText: "ISBN"),
                      validator: (value) {
                        if (value.isEmpty) return "ISBN cannot be empty";
                        return null;
                      },
                      onChanged: (value) {
                        book.ISBN = int.parse(value);
                      },
                    ),
                    TextFormField(
                      enabled: !scraped,
                      initialValue: book.title,
                      decoration: InputDecoration(hintText: "Title"),
                      validator: (value) {
                        if (value.isEmpty) return "Title cannot be empty";
                        return null;
                      },
                      onChanged: (value) {
                        book.title = value;
                      },
                    ),
                    TextFormField(
                      enabled: !scraped,
                      initialValue: book.author,
                      decoration: InputDecoration(hintText: "Author"),
                      validator: (value) {
                        if (value.isEmpty) return "Author cannot be empty";
                        return null;
                      },
                      onChanged: (value) {
                        book.author = value;
                      },
                    ),
                    TextFormField(
                      enabled: !scraped,
                      initialValue: book.description,
                      decoration: InputDecoration(hintText: "Description"),
                      onChanged: (value) {
                        book.description = value;
                      },
                    ),
                    TextFormField(
                      enabled: !scraped,
                      initialValue: book.totalPages.toString(),
                      decoration: InputDecoration(hintText: "Number of Pages"),
                      validator: (value) {
                        if (value.isEmpty)
                          return "Number of pages cannot be empty";
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        book.totalPages = int.parse(value);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Completed"),
                        Checkbox(
                            value: completedCheckBox,
                            onChanged: (val) {
                              setState(() {
                                completedCheckBox = val;

                                if (val)
                                  book.currentPage = book.totalPages;
                                else {
                                  if (!currentPageController.text.isEmpty) {
                                    book.currentPage =
                                        int.parse(currentPageController.text);
                                  } else
                                    book.currentPage = null;
                                }
                              });
                            }),
                      ],
                    ),
                    TextFormField(
                      enabled: !completedCheckBox,
                      controller: currentPageController,
                      decoration: InputDecoration(
                          hintText: "Current Page",
                          contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        book.currentPage = int.parse(value);
                      },
                    ),
                    SizedBox(height: 10,),
                    Container(
                      // color: Colors.grey,
                      child: RatingBar.builder(
                          initialRating: 0,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 1),
                          itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                          onRatingUpdate: (rating) async {
                            book.rating = (rating * 2).toInt();
                          }),
                    ),
                    DropdownButton<int>(
                      value: dropdownValue,
                      items: bookshelfList?.map((item) {
                            return DropdownMenuItem(
                              child: Text(item.name),
                              value: item.bookshelfID,
                            );
                          })?.toList() ??
                          [],
                      onChanged: (int value) {
                        setState(() {
                          print(value);
                          dropdownValue = value;
                          book.bookshelfID = value;
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
            actions: [cancelButton, continueButton],
          );
        });
      });
}
