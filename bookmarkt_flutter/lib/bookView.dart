import 'dart:convert';
import 'dart:io';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';

class bookView extends StatefulWidget {
  @override
  _bookViewState createState() => _bookViewState();
}

class _bookViewState extends State<bookView> {
  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            bookHeader(args),
            Container(
              height: 100,
              // color: Colors.pink,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pages Read:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        "${args.book.currentPage}/${args.book.totalPages}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  CircularPercentIndicator(
                    radius: 50,
                    lineWidth: 5,
                    percent: (args.book.currentPage / args.book.totalPages),
                    center:
                        Icon(Icons.book, color: Theme.of(context).primaryColor),
                    progressColor: Colors.green,
                    backgroundColor: Colors.grey,
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  CircularPercentIndicator(
                    radius: 50,
                    lineWidth: 5,
                    percent: 1,
                    center:
                    Icon(Icons.watch, color: Theme.of(context).primaryColor),
                    progressColor: Colors.green,
                    backgroundColor: Colors.grey,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Time Read:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        "${args.book.totalTimeRead} minutes",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}

Container bookHeader(args) {
  return Container(
    height: 197,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: args.book.bookInstanceID,
          child: Image.network(
              "http://${args.url}:5000/getThumbnail?path=${args.book.thumbnail}"),
        ),
        SizedBox(
          height: 20,
          width: 10,
        ),
        Expanded(
          child: Container(
            // color: Colors.red,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  args.book.title,
                  style: TextStyle(fontSize: 30),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "By " + args.book.author,
                  style: TextStyle(color: Colors.grey, fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  args.book.publishedDate,
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                Container(
                  // color: Colors.grey,
                  child: RatingBar.builder(
                      initialRating: args.book.rating / 2,
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

                        final response = await http.put(
                            "http://${args.url}:5000/users/${args.user.userID}/books/${args.book.bookInstanceID}/edit?rating=${rating * 2}");
                      }),
                ),
              ],
            ),
          ),
        )
      ],
    ),
  );
}
