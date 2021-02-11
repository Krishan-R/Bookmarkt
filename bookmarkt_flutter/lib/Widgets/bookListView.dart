import 'dart:convert';
import 'dart:io';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/allBooks.dart';
import 'package:bookmarkt_flutter/drawer.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

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
                Navigator.pushNamed(context, '/book', arguments: NavigatorArguments(args.user, args.url, book: data[index]));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Hero(
                      tag: data[index].bookInstanceID,
                      child: Image.network(
                          "http://${args.url}:5000/getThumbnail?path=${data[index].thumbnail}"),
                    ),
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