import 'dart:convert';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Models/bookshelf.dart';
import 'package:bookmarkt_flutter/Widgets/bookListView.dart';
import 'package:bookmarkt_flutter/drawer.dart';
import 'package:bookmarkt_flutter/library.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:http/http.dart' as http;

class homepage extends StatefulWidget {
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text("Home"),
          ),
          drawer: myDrawer(args),
          // body: Text("homepage"),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                recentDashboard(args: args),
                Divider(thickness: 2),
              ],
            ),
          )),
    );
  }
}

class recentDashboard extends StatefulWidget {
  NavigatorArguments args;

  recentDashboard({Key key, this.args}) : super(key: key);

  @override
  _recentDashboardState createState() => _recentDashboardState();
}

class _recentDashboardState extends State<recentDashboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recently Read",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(height: 5),
          FutureBuilder(
            future: getRecentBooks(widget.args),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Book> bookList = snapshot.data;

                if (bookList.length == 0) {
                  return Text("You've not read any books");
                }

                return Container(
                  height: 200,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Card(
                        child: InkWell(
                          onTap: () async {
                            List<Bookshelf> bookshelfList =
                                await getBookshelfList(widget.args);

                            Navigator.pushNamed(context, '/book',
                                arguments: NavigatorArguments(
                                    widget.args.user, widget.args.url,
                                    bookshelfList: bookshelfList,
                                    book: bookList[index])).then((value) => setState(() {}));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 110,
                                height: 170,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Hero(
                                    tag: bookList[index].bookInstanceID,
                                    child: Image.network(
                                      "http://${widget.args.url}:5000/getThumbnail?path=${bookList[index].thumbnail}",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: 110,
                                  child: Text(
                                    bookList[index].title,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(

                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );

                return Text("has data");
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            },
          )
        ],
      ),
    );
  }
}

Future<List<Book>> getRecentBooks(NavigatorArguments args) async {
  List<Book> bookList = [];

  final response = await http
      .get("http://${args.url}:5000/users/${args.user.userID}/recent");

  Iterable i = json.decode(response.body);

  for (var bookJson in i) {
    Book book = Book.fromJson(bookJson["data"]);
    bookList.add(book);
  }

  return bookList;
}
