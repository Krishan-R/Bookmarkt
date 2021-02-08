import 'dart:convert';
import 'dart:io';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/drawer.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class AllBooks extends StatefulWidget {
  @override
  _AllBooksState createState() => _AllBooksState();
}

class _AllBooksState extends State<AllBooks> {
  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text("Books"),
      ),
      drawer: myDrawer(args),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: getAllBookData(args),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Book> data = snapshot.data;
                  return bookListView(data, args);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }
}

ListView bookListView(data, args) {
  return ListView.builder(
    itemCount: data.length,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
        child: Container(
          height: 120,
          child: Card(
            child: InkWell(
              onTap: () {
                print("pressed " + data[index].bookshelfID.toString());
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Image.network(
                        "http://${args.url}:5000/getThumbnail?path=${data[index].thumbnail}"),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data[index].title,
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            data[index].author,
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "${data[index].currentPage.toString()}/${data[index].totalPages}",
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

Future<List<Book>> getAllBookData(args) async {
  List<Book> bookList = new List<Book>();

  try {
    final response = await http.get("http://${args.url}:5000/users/${args.user.userID.toString()}/books/all");

    Iterable i = json.decode(response.body);

    // print(i);
    bookList = List<Book>.from(i.map((model) => Book.fromJson(model)));

    // for (var i = 0; i < bookList.length; i++) {
    //   print(bookList[i].ISBN.toString() +
    //       " " +
    //       bookList[i].thumbnail);
    // }

    return bookList;
  } on SocketException {
    print("Error connecting to server");
  }
}
