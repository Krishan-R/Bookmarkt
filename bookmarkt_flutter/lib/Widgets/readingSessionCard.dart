import 'dart:convert';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Models/readingSession.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class readingSessionCard extends StatelessWidget {
  ReadingSession session;
  NavigatorArguments args;

  readingSessionCard({Key key, this.session, this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  () {
                    List<String> months = [
                      "January",
                      "February",
                      "March",
                      "April",
                      "May",
                      "June",
                      "July",
                      "August",
                      "September",
                      "October",
                      "November",
                      "December"
                    ];
                    return "${session.date.day.toString().padLeft(2, '0')} ${months[session.date.month - 1]} ${session.date.year}";
                  }(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                FutureBuilder(
                  future: getBook(this.args, session.bookInstanceID),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Flexible(
                        child: Text(
                          " - ${snapshot.data.title}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    return CircularProgressIndicator();
                  },
                )
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text("Pages Read", style: TextStyle(fontSize: 15)),
                    Text("${session.pagesRead} pages"),
                  ],
                ),
                Column(
                  children: [
                    Text("Time Read", style: TextStyle(fontSize: 15)),
                    Text("${session.timeRead} mins"),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

Future<Book> getBook(NavigatorArguments args, int bookInstanceID) async {
  Book book;

  final response = await http.get(
      "http://${args.url}:5000/users/${args.user.userID}/books/$bookInstanceID");

  book = Book.fromJson(json.decode(response.body));

  return book;
}