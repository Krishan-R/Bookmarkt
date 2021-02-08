import 'dart:convert';
import 'dart:io';

import 'package:bookmarkt_flutter/drawer.dart';
import 'package:bookmarkt_flutter/Models/bookshelf.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;


class Library extends StatefulWidget {
  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {

  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute
        .of(context)
        .settings
        .arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text("Library"),
      ),
      drawer: myDrawer(args),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Bookshelf>>(
              future: getBookshelfData(args),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Bookshelf> data = snapshot.data;
                  return bookshelfListView(data, args);
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
      );
  }
}

ListView bookshelfListView(data, args) {
  return ListView.builder(
    itemCount: data.length,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
        child: Card(
          child: ListTile(
            onTap: () {
              print("tapped " + data[index].bookshelfID.toString());
              Navigator.pushNamed(context, '/bookshelf', arguments: NavigatorArguments(args.user, args.url, bookshelfID: data[index].bookshelfID));
            },
            onLongPress: () {
              longPressDialog(context, args, data[index].bookshelfID, data[index].name);
            },
            title: Text(data[index].name),
          ),
        ),
      );
    },
  );
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
          final response = await http.post(
              "http://" + args.url + ":5000/users/" +
                  args.user.userID.toString() + "/bookshelf/add?name=" +
                  bookshelfNameController.text);
          if (response.body == "added new bookshelf") {
            // Navigator.pushNamedAndRemoveUntil(context, "/library", (route) => false, arguments: NavigatorArguments(args.user, args.url));
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

longPressDialog(BuildContext context, NavigatorArguments args, int bookshelfID, String bookshelfName) {

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
        FlatButton(onPressed: () {
          renameDialog(context, args, bookshelfID, bookshelfName);
        },
            child: Text("Rename")),
        FlatButton(onPressed: () {},
            child: Text("Delete"))
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

renameDialog(BuildContext context, NavigatorArguments args, int bookshelfID, String bookshelfName) {
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

          final response = await http.put(
              "http://" + args.url + ":5000/users/" +
                  args.user.userID.toString() + "/bookshelf/" + bookshelfID.toString() + "/rename?name=" +
                  bookshelfRenameController.text);

          if (response.body == "renamed bookshelf") {
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

Future<List<Bookshelf>> getBookshelfData(args) async {
  List<Bookshelf> bookshelfList = new List<Bookshelf>();
  try {
    final response = await http.get("http://" +
        args.url +
        ":5000/users/" +
        args.user.userID.toString() +
        "/bookshelf/all");

    Iterable i = json.decode(response.body);
    bookshelfList =
    List<Bookshelf>.from(i.map((model) => Bookshelf.fromJson(model)));

    // for (var i = 0; i < bookshelfList.length; i++) {
    //   print(bookshelfList[i].name +
    //       " " +
    //       bookshelfList[i].bookshelfID.toString());
    // }
    return bookshelfList;
  } on SocketException {
    print("Error connecting to server");
  }
}
