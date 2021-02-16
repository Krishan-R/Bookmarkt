import 'dart:convert';
import 'dart:io';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/allBooks.dart';
import 'package:bookmarkt_flutter/drawer.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

ListView bookListView(bookList, args) {

  // for (int i=0; i<bookList.length; i++) {
  //   print(bookList[i]);
  // }

  return ListView.builder(
    itemCount: bookList.length,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
        child: Container(
          height: 120,
          child: Card(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/book', arguments: NavigatorArguments(args.user, args.url, book: bookList[index]));
              },
              onLongPress: () {
                print(bookList[index].title);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Hero(
                      tag: bookList[index].bookInstanceID,
                      child: Image.network(
                          "http://${args.url}:5000/getThumbnail?path=${bookList[index].thumbnail}"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookList[index].title,
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            bookList[index].author,
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "${bookList[index].currentPage.toString()}/${bookList[index].totalPages}",
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