import 'dart:io';
import 'package:bookmarkt_flutter/Models/API%20requests.dart';
import 'package:bookmarkt_flutter/Models/bookshelf.dart';
import 'package:bookmarkt_flutter/Pages/drawer.dart';
import 'package:bookmarkt_flutter/Models/navigatorArguments.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class Library extends StatefulWidget {
  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  callback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;

    return WillPopScope(
      onWillPop: () async {
        if (_scaffoldKey.currentState.isDrawerOpen) {
          Navigator.of(context).pop();
        } else {
          _scaffoldKey.currentState.openDrawer();
        }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("Library"),
          ),
          drawer: myDrawer(args),
          body: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<Bookshelf>>(
                  future: getBookshelfList(args),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Bookshelf> data = snapshot.data;

                      if (data.isEmpty) {
                        return Center(
                          child: Text(
                            "No bookshelves have been added",
                            style: TextStyle(color: Colors.grey, fontSize: 20),
                          ),
                        );
                      } else {
                        return bookshelfListView(
                            args: args, bookshelfList: data, callback: callback);
                      }
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              AddBookshelfDialog(context, args);
            },
          ),
        ),
      ),
    );
  }
}

class bookshelfListView extends StatefulWidget {
  NavigatorArguments args;
  List<Bookshelf> bookshelfList;
  Function callback;

  bookshelfListView({Key key, this.args, this.bookshelfList, this.callback}) : super(key: key);

  @override
  _bookshelfListViewState createState() => _bookshelfListViewState();
}

class _bookshelfListViewState extends State<bookshelfListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.bookshelfList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
          child: Card(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/bookshelf',
                        arguments: NavigatorArguments(
                            widget.args.user, widget.args.url,
                            bookshelfID:
                                widget.bookshelfList[index].bookshelfID,
                            bookshelfName: widget.bookshelfList[index].name,
                            bookshelfList: widget.bookshelfList))
                    .then((value) => widget.callback());
              },
              onLongPress: () {
                longPressBookshelfDialog(
                    context,
                    widget.args,
                    widget.bookshelfList[index].bookshelfID,
                    widget.bookshelfList[index].name);
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bookshelfList[index].name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      "${widget.bookshelfList[index].bookCount.toString()} ${widget.bookshelfList[index].bookCount == 1 ? "book" : "books"}",
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

AddBookshelfDialog(BuildContext context, NavigatorArguments args) {
  TextEditingController bookshelfNameController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = FlatButton(
    child: Text("Add"),
    onPressed: () async {
      if (_formKey.currentState.validate()) {
        try {
          final response = await http.post("http://" +
              args.url +
              ":5000/users/" +
              args.user.userID.toString() +
              "/bookshelf/add?name=" +
              bookshelfNameController.text);
          if (response.statusCode == 201) {
            // Navigator.pop(context);
            Navigator.pushReplacementNamed(context, "/library",
                arguments: NavigatorArguments(args.user, args.url));
          }
        } on SocketException {
          print("Cannot connect to server");
        }
      }
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Add Bookshelf"),
    content: Form(
      key: _formKey,
      child: TextFormField(
        controller: bookshelfNameController,
        decoration: InputDecoration(hintText: "Bookshelf Name"),
        validator: (value) {
          if (value.isEmpty) return "Bookshelf name cannot be empty";
          return null;
        },
      ),
    ),
    actions: [
      cancelButton,
      continueButton,
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

longPressBookshelfDialog(BuildContext context, NavigatorArguments args,
    int bookshelfID, String bookshelfName) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Edit " + bookshelfName),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlatButton(
          child: Text("Rename"),
          onPressed: () {
            renameDialog(context, args, bookshelfID, bookshelfName);
          },
        ),
        FlatButton(
            child: Text("Delete"),
            onPressed: () async {
              final response = await http.delete(
                  "http://${args.url}:5000/users/${args.user.userID.toString()}/bookshelf/$bookshelfID/delete");

              if (response.statusCode == 200) {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/library",
                    arguments: args);
              } else {
                Fluttertoast.showToast(msg: "Error deleting Bookshelf");
              }
            }),
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

renameDialog(BuildContext context, NavigatorArguments args, int bookshelfID,
    String bookshelfName) {
  TextEditingController bookshelfRenameController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = FlatButton(
    child: Text("Rename"),
    onPressed: () async {
      if (_formKey.currentState.validate()) {
        try {
          final response = await http.put("http://" +
              args.url +
              ":5000/users/" +
              args.user.userID.toString() +
              "/bookshelf/" +
              bookshelfID.toString() +
              "/rename?name=" +
              bookshelfRenameController.text);

          if (response.statusCode == 200) {
            Navigator.pushReplacementNamed(context, "/library",
                arguments: NavigatorArguments(args.user, args.url));
          }
        } on SocketException {
          print("Cannot connect to server");
        }
      }
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Rename " + bookshelfName),
    content: Form(
      key: _formKey,
      child: TextFormField(
        controller: bookshelfRenameController,
        decoration: InputDecoration(hintText: "Bookshelf Name"),
        validator: (value) {
          if (value.isEmpty) return "Bookshelf name cannot be empty";
          return null;
        },
      ),
    ),
    actions: [
      cancelButton,
      continueButton,
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
