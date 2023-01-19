import 'dart:io';
import 'package:bookmarkt_flutter/Models/bookshelf.dart';
import 'package:bookmarkt_flutter/Models/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  bool goalCheckbox = false;
  DateTime goalDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  bool init = false;

  String appBarText;

  int bookISBN;
  String bookTitle;
  String bookAuthor;
  String bookDescription;
  int bookCurrentPage;
  int bookTotalPages;

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
      } else {
        print("not scraped");
      }

      if (args.book.completed != null) {
        completedCheckBox = args.book.completed;
      }

      if (args.book.publishedDate != null) {
        selectedDate = DateTime.parse(args.book.publishedDate);
      }

      bookISBN = args.book.ISBN;

      if (args.book.title == "null" || args.book.title == null) {
        bookTitle = "";
      } else {
        bookTitle = args.book.title;
      }

      if (args.book.author == "null" || args.book.author == null) {
        bookAuthor = "";
      } else {
        bookAuthor = args.book.author;
      }

      if (args.book.description == "null" || args.book.description == null) {
        bookDescription = "";
      } else {
        bookDescription = args.book.description;
      }

      if (args.book.rating == null) args.book.rating = 0;

      if (args.book.currentPage != null)
        currentPageController.text = args.book.currentPage.toString();

      bookTotalPages = args.book.totalPages;

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

      // set goal information
      if (args.book.goalDate != null) {
        goalDate = args.book.goalDate;
        goalCheckbox = true;
      }

      if (args.bookshelfID != null) {
        bookshelfDropdownValue = args.bookshelfID;
      }

      if (args.bookshelfList.isEmpty) {
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

      init = true;
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarText),
          actions: [
            Visibility(
              visible: args.redirect != "edit",
              child: FlatButton(
                child: Text("Add"),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    try {

                      args.book.ISBN = bookISBN;
                      args.book.title = bookTitle;
                      args.book.author = bookAuthor;
                      args.book.description = bookDescription;
                      args.book.currentPage = bookCurrentPage;
                      args.book.totalPages = bookTotalPages;

                      String bookshelfID = "";
                      if (bookshelfDropdownValue == -1 || bookshelfDropdownValue == null) {
                        bookshelfID = "";
                      } else {
                        bookshelfID = "&bookshelfID=$bookshelfDropdownValue";
                        args.book.bookshelfID = bookshelfDropdownValue;
                      }

                      if (args.book.currentPage == null) {
                        args.book.currentPage = 0;
                      }

                      String currentPage =
                          "&currentPage=${args.book.currentPage}";
                      String completed = "&completed=$completedCheckBox";
                      args.book.completed = completedCheckBox;
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

                        if ("${borrowingDate.year}-${borrowingDate.month.toString().padLeft(2, '0')}-${borrowingDate.day.toString().padLeft(2, '0')}" !=
                            "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}") {
                          borrowing +=
                              "&borrowingTime=${borrowingDate.year}-${borrowingDate.month.toString().padLeft(2, '0')}-${borrowingDate.day.toString().padLeft(2, '0')}";
                          args.book.borrowingTime = borrowingDate;
                        }
                      } else {
                        args.book.borrowingTo = null;
                        args.book.borrowingFrom = null;
                        args.book.borrowingTime = null;
                      }

                      String goal = "";
                      if (goalCheckbox) {
                        goal = "&goalDate=${goalDate.year}-${goalDate.month.toString().padLeft(2, '0')}-${goalDate.day.toString().padLeft(2, '0')}";
                        args.book.goalDate = goalDate;
                      }

                      final response = await http.post(
                          "http://${args.url}:5000/users/${args.user.userID.toString()}/books/add?isbn=${args.book.ISBN}$bookshelfID$currentPage$completed$rating$title$author$description$totalPages$publishedDate$borrowing$goal");

                      if (response.statusCode == 201) {

                        print("redirect:");
                        Navigator.pushNamedAndRemoveUntil(context, args.redirect, (r) => false, arguments: args);

                      } else if (response.statusCode == 403 || response.statusCode == 42) {

                        switch (response.body) {
                          case "currentPage value not valid":
                            Fluttertoast.showToast(msg: "Error with Current Page");
                            break;
                          case "Bookshelf does not belong to that user":
                          case "bookshelfID is not valid":
                          case "Bookshelf does not not exist":
                            Fluttertoast.showToast(msg: "Error with Bookshelf");
                            break;

                        }
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

                      String bookshelf = "";
                      if (bookshelfDropdownValue == null || bookshelfDropdownValue == -1) {
                        bookshelf = "&bookshelfID=null";
                        args.book.bookshelfID = null;
                      } else {
                        bookshelf = "&bookshelfID=$bookshelfDropdownValue";
                        args.book.bookshelfID = bookshelfDropdownValue;

                      }

                      if (bookCurrentPage == null) {
                        args.book.currentPage = 0;
                      } else {
                        args.book.currentPage = bookCurrentPage;
                      }

                      String currentPage =
                          "&currentPage=$bookCurrentPage";
                      String completed = "&completed=$completedCheckBox";

                      String title = "title=$bookTitle";
                      String author = "&author=$bookAuthor";
                      String description =
                          "&description=$bookDescription";
                      String totalPages = "&totalPages=$bookTotalPages";
                      String publishedDate =
                          "&publishedDate=${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

                      // if the book's data was entered manually
                      if (!args.book.automaticallyScraped) {
                        final response = await http.put(
                            "http://${args.url}:5000/books/$bookISBN?$title$author$description$totalPages$publishedDate");
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

                        if ("${borrowingDate.year}-${borrowingDate.month.toString().padLeft(2, '0')}-${borrowingDate.day.toString().padLeft(2, '0')}" !=
                            "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}") {
                          borrowing +=
                              "&borrowingTime=${borrowingDate.year}-${borrowingDate.month.toString().padLeft(2, '0')}-${borrowingDate.day.toString().padLeft(2, '0')}";
                          args.book.borrowingTime = borrowingDate;
                        }
                      } else {
                        args.book.borrowingTo = null;
                        args.book.borrowingFrom = null;
                        args.book.borrowingTime = null;
                        borrowing =
                            "&borrowingFrom=null&borrowingTo=null&borrowingTime=null";
                      }

                      String goal = "";
                      if (goalCheckbox) {
                        goal = "&goalDate=${goalDate.year}-${goalDate.month.toString().padLeft(2, '0')}-${goalDate.day.toString().padLeft(2, '0')}";
                        args.book.goalDate = goalDate;
                      } else {
                        goal = "&goalDate=null";
                        args.book.goalDate = null;
                      }

                      args.book.ISBN = bookISBN;
                      args.book.title = bookTitle;
                      args.book.author = bookAuthor;
                      args.book.description = bookDescription;
                      args.book.totalPages = bookTotalPages;
                      args.book.completed = completedCheckBox;

                      final response = await http.put(
                          "http://${args.url}:5000/users/${args.user.userID.toString()}/books/${args.book.bookInstanceID}/edit?$currentPage$completed$bookshelf$borrowing$goal$totalPages");

                      //todo request to update book information if not automaticallyscraped

                      Navigator.pop(context);

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
                    enabled: bookISBN == null || !scraped,
                    initialValue: bookISBN == null ? null : bookISBN.toString() ,
                    decoration: InputDecoration(hintText: "ISBN"),
                    validator: (value) {
                      if (value.isEmpty) return "ISBN cannot be empty";
                      return null;
                    },
                    onChanged: (value) {
                      bookISBN = int.parse(value);
                    },
                  ),
                  TextFormField(
                    enabled: !scraped,
                    initialValue: bookTitle,
                    decoration: InputDecoration(hintText: "Title"),
                    validator: (value) {
                      if (value.isEmpty) return "Title cannot be empty";
                      return null;
                    },
                    onChanged: (value) {
                      bookTitle = value;
                    },
                  ),
                  TextFormField(
                    enabled: !scraped,
                    initialValue: bookAuthor,
                    decoration: InputDecoration(hintText: "Author"),
                    validator: (value) {
                      if (value.isEmpty) return "Author cannot be empty";
                      return null;
                    },
                    onChanged: (value) {
                      bookAuthor = value;
                    },
                  ),
                  TextFormField(
                    enabled: !scraped,
                    initialValue: bookDescription,
                    maxLines: 4,
                    decoration: InputDecoration(hintText: "Description"),
                    onChanged: (value) {
                      bookDescription = value;
                    },
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          enabled: !completedCheckBox,
                          controller: currentPageController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              hintText: "Current Page",
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10)),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value.isNotEmpty &&
                                int.parse(value) > bookTotalPages)
                              return "Current Page is larger than total";
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isEmpty) bookCurrentPage = 0;
                            bookCurrentPage = int.parse(value);
                          },
                        ),
                      ),
                      Flexible(
                        child: TextFormField(
                          initialValue: ((){
                            if (bookTotalPages == null) return null;
                            else {
                              return bookTotalPages.toString();
                            }
                          }()),
                          textAlign: TextAlign.center,
                          decoration:
                              InputDecoration(hintText: "Number of Pages"),
                          validator: (value) {
                            if (value.isEmpty)
                              return "Number of pages cannot be empty";
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            bookTotalPages = int.parse(value);
                          },
                        ),
                      ),
                    ],
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
                          value: completedCheckBox,
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (val) {
                            setState(() {
                              completedCheckBox = val;
                              // if checked sets current page to max page
                              if (val)
                                bookCurrentPage = bookTotalPages;
                              else {
                                if (currentPageController.text.isNotEmpty) {
                                  bookCurrentPage =
                                      int.parse(currentPageController.text);
                                } else
                                  bookCurrentPage = 0;
                              }
                            });
                          }),
                      Text("Completed"),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: borrowingCheckBox,
                          activeColor: Theme.of(context).colorScheme.primary,
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
                  Row(
                    children: [
                      Checkbox(
                          value: goalCheckbox,
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (value) {
                            setState(() {
                              goalCheckbox = !goalCheckbox;
                            });
                          }),
                      Text("Reading Goal"),
                      SizedBox(width: 10),
                      Visibility(
                        visible: goalCheckbox,
                        child: FlatButton(
                            onPressed: () async {
                              DateTime picked = await showDatePicker(
                                  context: context,
                                  initialDate: goalDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100));
                              if (picked != null && picked != goalDate)
                                setState(() {
                                  goalDate = picked;
                                });
                            },
                            child: Text(
                                "${goalDate.year}-${goalDate.month.toString().padLeft(2, '0')}-${goalDate.day.toString().padLeft(2, '0')}")),
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
