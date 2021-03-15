import 'package:bookmarkt_flutter/Models/API%20requests.dart';
import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Models/navigatorArguments.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

              if (bookList.isEmpty) {
                return Center(
                    child: Text(
                  "No Books Found",
                  style: TextStyle(fontSize: 20),
                ));
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: bookList.length,
                  itemBuilder: (context, index) {
                    return Visibility(
                      // visible: true,
                      visible: bookList[index].ISBN != null,
                      child: Container(
                        height: 120,
                        child: Card(
                          child: InkWell(
                            onTap: () async {

                              final response = await http.post("http://${args.url}:5000/books/scrape?selfLink=${bookList[index].selfLink}");

                              Book book = Book.fromJsonBookData(json.decode(response.body));

                              args.book = book;
                              args.bookshelfList = await getBookshelfList(args);

                              print(bookList[index].selfLink);
                              print(book.totalPages);

                              Navigator.pushNamed(context, "/addBook", arguments: args);
                            },
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            "Total Pages: ${bookList[index].totalPages.toString() ?? "unknown"}",
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.grey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "Published Date: ${bookList[index].publishedDate ?? "unknown"}",
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


