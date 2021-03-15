import 'package:bookmarkt_flutter/Models/API%20requests.dart';
import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Models/bookshelf.dart';
import 'package:bookmarkt_flutter/Models/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class bookListView extends StatefulWidget {
  NavigatorArguments args;
  List<Book> bookList;

  bookListView({Key key, this.args, this.bookList}) : super(key: key);

  @override
  _bookListViewState createState() => _bookListViewState();
}

class _bookListViewState extends State<bookListView> {
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
              child: InkWell(
                onTap: () async {
                  List<Bookshelf> bookshelfList =
                      await getBookshelfList(widget.args);

                  Navigator.pushNamed(context, '/book',
                          arguments: NavigatorArguments(
                              widget.args.user, widget.args.url,
                              bookshelfList: bookshelfList,
                              book: widget.bookList[index]))
                      .then((value) => setState(() {}));
                },
                onLongPress: () {
                  widget.args.book = widget.bookList[index];
                  longPressBookDialog(
                          context,
                          setState,
                          widget.args,
                          widget.bookList[index].bookInstanceID,
                          widget.bookList[index].title);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Hero(
                          tag: widget.bookList[index].bookInstanceID,
                          child: Image.network(
                              "http://${widget.args.url}:5000/getThumbnail?path=${widget.bookList[index].thumbnail}"),
                        ),
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
                              )
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

longPressBookDialog(BuildContext context, setState, NavigatorArguments args,
    int bookInstanceID, String bookTitle) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(bookTitle),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlatButton(
          child: Text("Edit"),
          onPressed: () async {
            args.redirect = "edit";

            List<Bookshelf> bookshelfList = await getBookshelfList(args);
            args.bookshelfList = bookshelfList;

            Navigator.pushNamed(context, "/addBook", arguments: args)
                .then((value) => Navigator.pop(context)).then((value) => setState(() {}));
          },
        ),
        FlatButton(
          child: Text("Delete"),
          onPressed: () async {
            final response = await http.delete(
                "http://${args.url}:5000/users/${args.user.userID.toString()}/books/delete?bookInstanceID=$bookInstanceID");

            if (response.body == "deleted book instance") {
              Navigator.pushReplacementNamed(context, "/allBooks",
                  arguments: args);
            } else {
              print(response.body);
              Fluttertoast.showToast(msg: "Error deleting Book");
            }
          },
        ),
      ],
    ),
    actions: [
      cancelButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
