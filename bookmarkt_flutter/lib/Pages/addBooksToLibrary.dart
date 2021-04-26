import 'dart:convert';
import 'package:bookmarkt_flutter/Models/API%20requests.dart';
import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Models/bookshelf.dart';
import 'package:bookmarkt_flutter/Pages/library.dart';
import 'package:bookmarkt_flutter/Widgets/addBookAlert.dart';
import 'package:bookmarkt_flutter/Widgets/bookListView.dart';
import 'package:bookmarkt_flutter/Models/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class AddBooksToBookshelf extends StatefulWidget {
  @override
  _AddBooksToBookshelfState createState() => _AddBooksToBookshelfState();
}

class _AddBooksToBookshelfState extends State<AddBooksToBookshelf> {
  List<Book> bookList;

  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Books to Bookshelf"),
          actions: [
            FlatButton(
              child: Text("Add"),
              onPressed: () async {
                for (Book book in bookList) {
                  if (book.isSelected) {
                    await addBookToBookshelf(
                        args, book.bookInstanceID, args.bookshelfID);
                  }
                }
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: FutureBuilder(
          future: getAllBookData(args),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              bookList = snapshot.data;

              return SelectableBookCards(
                args: args,
                bookList: bookList,
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class SelectableBookCards extends StatefulWidget {
  NavigatorArguments args;
  List<Book> bookList;

  SelectableBookCards({Key key, this.args, this.bookList}) : super(key: key);

  @override
  _SelectableBookCardsState createState() => _SelectableBookCardsState();
}

class _SelectableBookCardsState extends State<SelectableBookCards> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.bookList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
          child: Container(
            height: 120,
            child: Card(
              color: widget.bookList[index].isSelected
                  ? Colors.grey[300]
                  : Colors.white,
              child: InkWell(
                onTap: () async {
                  setState(() {
                    widget.bookList[index].isSelected =
                        !widget.bookList[index].isSelected;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Image.network(
                            "http://${widget.args.url}:5000/getThumbnail?path=${widget.bookList[index].thumbnail}"),
                      ),
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
                                widget.bookList[index].title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                widget.bookList[index].author,
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                "${widget.bookList[index].currentPage.toString()}/${widget.bookList[index].totalPages}",
                                style: TextStyle(color: Colors.grey),
                              ),
                              RatingBar.builder(
                                initialRating:
                                widget.bookList[index].rating / 2,
                                minRating: 0,
                                direction: Axis.horizontal,
                                itemSize: 15,
                                itemCount: 5,
                                allowHalfRating: true,
                                ignoreGestures: true,
                                itemPadding: EdgeInsets.symmetric(horizontal: 0.5),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {},
                              ),
                            ],
                          ),
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
}
