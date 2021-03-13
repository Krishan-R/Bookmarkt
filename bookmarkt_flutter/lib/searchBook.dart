import 'dart:convert';
import 'dart:io';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Models/readingSession.dart';
import 'package:bookmarkt_flutter/Widgets/readingSessionCard.dart';
import 'package:bookmarkt_flutter/bookshelf.dart';
import 'package:bookmarkt_flutter/library.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';

class SearchBook extends StatefulWidget {
  @override
  _SearchBookState createState() => _SearchBookState();
}

class _SearchBookState extends State<SearchBook> {
  String searchValue;
  ScrollController scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Flexible(
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search...",
                    isDense: true,
                  ),
                  autofocus: true,
                  onChanged: (value) {
                    searchValue = value;
                  },
                  onEditingComplete: () {
                    setState(() {
                      FocusScope.of(context).unfocus();
                      scrollController.animateTo(
                          scrollController.position.minScrollExtent,
                          duration: Duration(milliseconds: 1000),
                          curve: Curves.fastOutSlowIn);
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    FocusScope.of(context).unfocus();
                    scrollController.animateTo(
                        scrollController.position.minScrollExtent,
                        duration: Duration(milliseconds: 1000),
                        curve: Curves.fastOutSlowIn);
                  });
                },
              )
            ],
          ),
        ),
        body: FutureBuilder(
          future: getSearchBooks(searchValue),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Book> bookList = snapshot.data;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: bookList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 120,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child:
                                      Image.network(bookList[index].thumbnail)),
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bookList[index].title,
                                        style: TextStyle(fontSize: 18),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        bookList[index].author ??
                                            "No Author Found",
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "Total Pages: ${bookList[index].totalPages.toString()??
                                            "unknown"}",
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "Published Date: ${bookList[index].publishedDate??
                                            "unknown"}",
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Center(
              child: Text(
                "Please Search for a book",
                style: TextStyle(fontSize: 20),
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<List<Book>> getSearchBooks(String search) async {
  print("searching");

  List<Book> bookList = [];

  try {
    if (search == "" || search == null) {
      return null;
    }

    final response = await http.get(
        "https://www.googleapis.com/books/v1/volumes?q=$search&maxResults=40&orderBy=relevance");

    Iterable i = json.decode(response.body)["items"];

    bookList = List<Book>.from(i.map((model) => Book.fromSearchJson(model)));

    print(bookList.length);

    for (Book a in bookList) {
      print("googleID: ${a.googleID}");
      print("selfLink: ${a.selfLink}");
      print(a.title);
      print("author: ${a.author}");
      print(a.description);
      print("total pages: ${a.totalPages}");
      print("thumbnail: ${a.thumbnail}");
      print(a.publishedDate);
      print("==========");
    }

    return bookList;
  } on SocketException {
    Fluttertoast.showToast(msg: "Error Searching for Book");
    return null;
  }
}
