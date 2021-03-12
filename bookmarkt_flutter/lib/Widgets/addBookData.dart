import 'dart:io';

import 'package:bookmarkt_flutter/Models/bookshelf.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:http/http.dart' as http;

class addBook extends StatefulWidget {
  @override
  _addBookState createState() => _addBookState();
}

class _addBookState extends State<addBook> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController currentPageController = new TextEditingController();

  int bookshelfDropdownValue = -1;
  String borrowingDropdownValue;
  bool borrowingCheckBox = false;
  String borrowingName = "";
  DateTime borrowingDate = DateTime.now();
  bool completedCheckBox = false;
  DateTime selectedDate = DateTime.now();
  bool init = false;

  String appBarText;

  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;

    bool scraped = true;

    if (args.book.automaticallyScraped != null &&
        !args.book.automaticallyScraped) {
      scraped = false;
    } else {
      if (args.book.title == null) {
        scraped = false;
      } else {
        scraped = true;
      }
    }

    if (args.redirect == "edit") {
      appBarText = "Edit Book";
    } else {
      appBarText = "Add New Book";
    }

    //sets book variables on first build
    if (!init) {
      if (scraped) {
        if (args.book.publishedDate != null) {
          selectedDate = DateTime.parse(args.book.publishedDate);
        }

        if (args.book.description == "null") args.book.description = "";
        if (args.book.rating == null) args.book.rating = 0;
        if (args.book.currentPage != null)
          currentPageController.text = args.book.currentPage.toString();
      } else {
        print("not scraped");
        if (args.book.totalPages == null) args.book.totalPages = 1;
        if (args.book.rating == null) args.book.rating = 0;
        if (args.book.currentPage != null)
          currentPageController.text = args.book.currentPage.toString();
      }

      if (args.book.completed != null) {
        completedCheckBox = args.book.completed;
      }

      // sets borrowing information
      if (args.book.borrowingTo != null) {
        borrowingCheckBox = true;
        borrowingDropdownValue = "to";
        borrowingName = args.book.borrowingTo;
      } else if (args.book.borrowingFrom != null) {
        borrowingCheckBox = true;
        borrowingDropdownValue = "from";
        borrowingName = args.book.borrowingFrom;
      }

      if (args.book.borrowingTime != null) {
        borrowingDate = args.book.borrowingTime;
      }

      init = true;
    }

    if (args.bookshelfID != null) {
      bookshelfDropdownValue = (args.bookshelfID);
      args.book.bookshelfID = args.bookshelfID;
    }

    if (args.bookshelfList.isEmpty) {
      print("no bookshelves found");
      Bookshelf emptyBookshelf =
          Bookshelf(bookshelfID: -1, name: "No Bookshelves");
      args.bookshelfList.add(emptyBookshelf);
      bookshelfDropdownValue = -1;
    } else {
      // prepends blank bookshelf
      if (args.bookshelfList[0].name != "(No bookshelf)" &&
          args.bookshelfList[0].name != "No Bookshelves") {
        args.bookshelfList
            .insert(0, Bookshelf(bookshelfID: -1, name: "(No bookshelf)"));
      }
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarText),
          actions: [
            Visibility(
              visible: args.redirect != "edit",
              child: FlatButton(
                child: Text(
                  "Add",
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    try {
                      String bookshelfID = "";
                      if (args.book.bookshelfID == null) {
                        bookshelfID = "";
                      } else if (args.book.bookshelfID == -1) {
                        bookshelfID = "";
                      } else {
                        bookshelfID = "&bookshelfID=${args.book.bookshelfID}";
                      }

                      if (args.book.currentPage == null) {
                        args.book.currentPage = 1;
                      }

                      String currentPage =
                          "&currentPage=${args.book.currentPage}";
                      String completed = "&completed=$completedCheckBox";
                      String rating = "&rating=${args.book.rating}";

                      String title = "&title=${args.book.title}";
                      String author = "&author=${args.book.author}";
                      String description =
                          "&description=${args.book.description}";
                      String totalPages = "&totalPages=${args.book.totalPages}";
                      String publishedDate =
                          "&publishedDate=${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

                      String borrowing = "";
                      if (borrowingCheckBox) {

                        if (borrowingDropdownValue == "from") {
                          borrowing += "&borrowingFrom=$borrowingName";
                          args.book.borrowingFrom = borrowingName;
                        } else {
                          borrowing += "&borrowingTo=$borrowingName";
                          args.book.borrowingTo = borrowingName;
                        }

                        if ("${borrowingDate.year}-${borrowingDate.month.toString().padLeft(2, '0')}-${borrowingDate.day.toString().padLeft(2, '0')}" != "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}") {
                          borrowing += "&borrowingTime=${borrowingDate.year}-${borrowingDate.month.toString().padLeft(2, '0')}-${borrowingDate.day.toString().padLeft(2, '0')}";
                          args.book.borrowingTime = borrowingDate;
                        }
                      }


                      final response = await http.post(
                          "http://${args.url}:5000/users/${args.user.userID.toString()}/books/add?isbn=${args.book.ISBN}$bookshelfID$currentPage$completed$rating$title$author$description$totalPages$publishedDate$borrowing");

                      if (response.body == "added new BookInstance") {
                        Navigator.popUntil(
                            context, ModalRoute.withName(args.redirect));
                        Navigator.pushReplacementNamed(context, args.redirect,
                            arguments: args);
                      }
                    } on SocketException {
                      print("Error connecting to server");
                    }
                  }
                },
              ),
            ),
            Visibility(
              visible: args.redirect == "edit",
              child: FlatButton(
                child: Text(
                  "Edit",
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    try {
                      String bookshelfID = "";
                      if (args.book.bookshelfID == null) {
                        bookshelfID = "";
                      } else if (args.book.bookshelfID == -1) {
                        bookshelfID = "";
                      } else {
                        bookshelfID = "&bookshelfID=${args.book.bookshelfID}";
                      }

                      if (args.book.currentPage == null) {
                        args.book.currentPage = 1;
                      }

                      String currentPage =
                          "&currentPage=${args.book.currentPage}";
                      String completed = "&completed=$completedCheckBox";

                      String title = "title=${args.book.title}";
                      String author = "&author=${args.book.author}";
                      String description =
                          "&description=${args.book.description}";
                      String totalPages = "&totalPages=${args.book.totalPages}";
                      String publishedDate =
                          "&publishedDate=${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

                      if (!args.book.automaticallyScraped) {
                        final response = await http.put(
                            "http://${args.url}:5000/books/${args.book.ISBN}?$title$author$description$totalPages$publishedDate");
                      }

                      String borrowing = "";
                      if (borrowingCheckBox) {

                        if (borrowingDropdownValue == "from") {
                          borrowing += "&borrowingFrom=$borrowingName";
                          args.book.borrowingFrom = borrowingName;
                        } else {
                          borrowing += "&borrowingTo=$borrowingName";
                          args.book.borrowingTo = borrowingName;
                        }

                        if ("${borrowingDate.year}-${borrowingDate.month.toString().padLeft(2, '0')}-${borrowingDate.day.toString().padLeft(2, '0')}" != "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}") {
                          borrowing += "&borrowingTime=${borrowingDate.year}-${borrowingDate.month.toString().padLeft(2, '0')}-${borrowingDate.day.toString().padLeft(2, '0')}";
                          args.book.borrowingTime = borrowingDate;
                        }
                      }

                      final response = await http.put(
                          "http://${args.url}:5000/users/${args.user.userID.toString()}/books/${args.book.bookInstanceID}/edit?currentPage=${args.book.currentPage}&completed=$completedCheckBox&bookshelfID=${args.book.bookshelfID}$borrowing");

                      Navigator.pop(context);

                      print(response.body);
                    } on SocketException {
                      print("Error connecting to server");
                    }
                  }
                },
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    enabled: false,
                    initialValue: args.book.ISBN.toString(),
                    decoration: InputDecoration(hintText: "ISBN"),
                    validator: (value) {
                      if (value.isEmpty) return "ISBN cannot be empty";
                      return null;
                    },
                    onChanged: (value) {
                      args.book.ISBN = int.parse(value);
                    },
                  ),
                  TextFormField(
                    enabled: !scraped,
                    initialValue: args.book.title,
                    decoration: InputDecoration(hintText: "Title"),
                    validator: (value) {
                      if (value.isEmpty) return "Title cannot be empty";
                      return null;
                    },
                    onChanged: (value) {
                      args.book.title = value;
                    },
                  ),
                  TextFormField(
                    enabled: !scraped,
                    initialValue: args.book.author,
                    decoration: InputDecoration(hintText: "Author"),
                    validator: (value) {
                      if (value.isEmpty) return "Author cannot be empty";
                      return null;
                    },
                    onChanged: (value) {
                      args.book.author = value;
                    },
                  ),
                  TextFormField(
                    enabled: !scraped,
                    initialValue: args.book.description,
                    maxLines: 4,
                    decoration: InputDecoration(hintText: "Description"),
                    onChanged: (value) {
                      args.book.description = value;
                    },
                  ),
                  TextFormField(
                    enabled: !scraped,
                    initialValue: args.book.totalPages.toString(),
                    decoration: InputDecoration(hintText: "Number of Pages"),
                    validator: (value) {
                      if (value.isEmpty)
                        return "Number of pages cannot be empty";
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      args.book.totalPages = int.parse(value);
                    },
                  ),
                  FlatButton(
                      onPressed: () async {
                        DateTime picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now());
                        if (picked != null && picked != selectedDate)
                          setState(() {
                            selectedDate = picked;
                          });
                      },
                      child: Text(
                          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}")),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Completed"),
                      Checkbox(
                          value: completedCheckBox,
                          onChanged: (val) {
                            // print(val);
                            setState(() {
                              completedCheckBox = val;
                              args.book.completed = completedCheckBox;
                              // if checked sets current page to max page
                              if (val)
                                args.book.currentPage = args.book.totalPages;
                              else {
                                if (!currentPageController.text.isEmpty) {
                                  args.book.currentPage =
                                      int.parse(currentPageController.text);
                                } else
                                  args.book.currentPage = 1;
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
                    validator: (value) {
                      if (value.isNotEmpty &&
                          int.parse(value) > args.book.totalPages)
                        return "Current Page is larger than total";
                      return null;
                    },
                    onChanged: (value) {
                      if (value.isEmpty) args.book.currentPage = 1;
                      args.book.currentPage = int.parse(value);
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Visibility(
                    visible: args.redirect != "edit",
                    child: Container(
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
                            args.book.rating = (rating * 2).toInt();
                          }),
                    ),
                  ),
                  Visibility(
                    visible: args.bookshelfID == null,
                    child: DropdownButton<int>(
                      value: bookshelfDropdownValue,
                      items: args.bookshelfList?.map((item) {
                            return DropdownMenuItem(
                              child: Text(item.name),
                              value: item.bookshelfID,
                            );
                          })?.toList() ??
                          [],
                      onChanged: (int value) {
                        setState(() {
                          bookshelfDropdownValue = value;
                          args.book.bookshelfID = value;
                        });
                      },
                    ),
                  ),
                  Visibility(
                    visible: args.bookshelfID != null,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        args.bookshelfName ?? "",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                          value: borrowingCheckBox,
                          onChanged: (value) {
                            setState(() {
                              borrowingCheckBox = !borrowingCheckBox;
                            });
                          }),
                      Text("Borrowing"),
                      SizedBox(width: 10),
                      Visibility(
                        visible: borrowingCheckBox,
                        child: DropdownButton<String>(
                          items: ["from", "to"].map((String value) {
                            return new DropdownMenuItem<String>(
                              child: Text(value),
                              value: value,
                            );
                          }).toList(),
                          value: borrowingDropdownValue,
                          onChanged: (value) {
                            setState(() {
                              borrowingDropdownValue = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Visibility(
                        visible: borrowingCheckBox,
                        child: Container(
                          width: 80,
                          // height: 25,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            initialValue: borrowingName,
                            decoration: InputDecoration(
                              hintText: "Name",
                              isDense: true,
                            ),
                            onChanged: (value) {
                              borrowingName = value;
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible: borrowingCheckBox,
                        child: FlatButton(
                            onPressed: () async {
                              DateTime picked = await showDatePicker(
                                  context: context,
                                  initialDate: borrowingDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100));
                              if (picked != null && picked != borrowingDate)
                                setState(() {
                                  borrowingDate = picked;
                                });
                            },
                            child: Text(
                                "${borrowingDate.year}-${borrowingDate.month.toString().padLeft(2, '0')}-${borrowingDate.day.toString().padLeft(2, '0')}")),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
