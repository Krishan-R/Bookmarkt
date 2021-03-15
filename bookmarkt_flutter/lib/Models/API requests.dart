import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Models/bookshelf.dart';
import 'package:bookmarkt_flutter/Models/navigatorArguments.dart';
import 'package:bookmarkt_flutter/Models/readingSession.dart';
import 'package:bookmarkt_flutter/Models/user.dart';
import 'package:fl_chart/fl_chart.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool> connectToServer(url) async {
  try {
    final response = await http.get("http://" + url + ":5000");
    if (response.body == "True") {
      return Future.value(true);
    }
  } on SocketException {
    return Future.value(false);
  }

  return Future.value(false);
}

Future<String> signUp(url, username, password, email) async {

  try {
    final response = await http.post("http://" + url + ":5000/users/add?username=" + username + "&email=" + email + "&password=" + password);
    print(response.body);

    if (response.body == "added new User") return "success";
    else if (response.body == "username already exists") return "usernameConflict";
    else if (response.body == "There is already an account associated with this email") return "emailConflict";

  } on SocketException {
    print("Cannot connect to server");
    return Future.value("SocketException");
  }
}

Future<User> loginToServer(url, username, password) async {
  try {
    final response = await http.get("http://" +
        url +
        ":5000/login?username=" +
        username +
        "&password=" +
        password);

    if (response.body == "User cannot be found" ||
        response.body == "incorrect credentials") {
      return null;
    } else {
      var jsonData = json.decode(response.body);
      User user = User(
          userID: jsonData["userID"],
          email: jsonData["email"],
          username: jsonData["username"]);

      final prefs = await SharedPreferences.getInstance();

      prefs.setString("user", json.encode(user));

      return user;
    }
  } on SocketException {
    print("Error communicating to server");
    return null;
  }
}

Future<Book> getBook(NavigatorArguments args, int bookInstanceID) async {
  Book book;

  final response = await http.get(
      "http://${args.url}:5000/users/${args.user.userID}/books/$bookInstanceID");

  book = Book.fromJson(json.decode(response.body));

  return book;
}

Future<List<Bookshelf>> getBookshelfList(args) async {
  List<Bookshelf> bookshelfList = [];
  try {
    final response = await http.get("http://" +
        args.url +
        ":5000/users/" +
        args.user.userID.toString() +
        "/bookshelf/all");

    Iterable i = json.decode(response.body);
    bookshelfList =
    List<Bookshelf>.from(i.map((model) => Bookshelf.fromJson(model)));

    return bookshelfList;
  } on SocketException {
    print("Error connecting to server");
  }
}

Future<String> getBookshelfName(
    NavigatorArguments args, int bookshelfID) async {
  if (bookshelfID == null) return "";

  final response = await http.get(
      "http://${args.url}:5000/users/${args.user.userID}/bookshelf/$bookshelfID");

  return json.decode(response.body)["name"];
}

Future<List<Book>> getBookshelfBookData(args) async {
  List<Book> bookList = [];

  try {
    final response = await http.get(
        "http://${args.url}:5000/users/${args.user.userID.toString()}/bookshelf/${args.bookshelfID}");

    if (response.body == "Bookshelf is empty") {
      return bookList;
    }

    Iterable i = json.decode(response.body)["books"];

    bookList = List<Book>.from(i.map((model) => Book.fromJson(model)));

    return bookList;
  } on SocketException {
    print("Error connecting to server");
  }
}

Future<List<Book>> getAllBookData(args) async {
  List<Book> bookList = [];

  try {
    final response = await http.get(
        "http://${args.url}:5000/users/${args.user.userID.toString()}/books/all");

    if (response.body == "No books") {
      return bookList;
    }

    Iterable i = json.decode(response.body);

    bookList = List<Book>.from(i.map((model) => Book.fromJson(model)));

    return bookList;
  } on SocketException {
    print("Error connecting to server");
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

Future<List<Book>> getUnreadBooks(NavigatorArguments args) async {
  List<Book> bookList = [];

  final response = await http.get("http://${args.url}:5000/users/${args.user.userID}/unread");

  Iterable i = json.decode(response.body)["books"];

  bookList = List<Book>.from(i.map((model) => Book.fromJson(model)));

  return bookList;
}

Future<List<ReadingSession>> getReadingSessions(
    NavigatorArguments args, int bookInstanceID) async {
  List<ReadingSession> sessionList = [];

  final response = await http.get(
      "http://${args.url}:5000/users/${args.user.userID}/books/$bookInstanceID/sessions");

  Iterable i = json.decode(response.body)["sessions"];

  sessionList = List<ReadingSession>.from(
      i.map((model) => ReadingSession.fromJson(model)));

  return sessionList;
}

Future<List<ReadingSession>> getAllReadingSessions(
    NavigatorArguments args) async {
  List<ReadingSession> sessionList = [];

  final response = await http.get(
      "http://${args.url}:5000/users/${args.user.userID}/readingSessions/all");

  Iterable i = json.decode(response.body)["sessions"];

  sessionList = List<ReadingSession>.from(
      i.map((model) => ReadingSession.fromJson(model)));

  return sessionList;
}

Future<Map> getReadingStatistics(NavigatorArguments args, int duration) async {
  List<FlSpot> timeList = [];
  List<FlSpot> pageList = [];
  Map dateData = {};

  try {
    final response = await http.get(
        "http://${args.url}:5000/users/${args.user.userID}/books/${args.book.bookInstanceID}/stats?time=${duration - 1}");

    Iterable time = json.decode(response.body)["statistics"]["time"];

    double maxY = 0;
    double xValue = 0;
    for (var val in time) {
      timeList.add(FlSpot(xValue, val["time"].toDouble()));
      dateData[xValue] = val["date"];

      if (val["time"].toDouble() > maxY) maxY = val["time"].toDouble();
      xValue += 1;
    }

    Map timeData = {
      "maxX": xValue.toDouble() - 1,
      "maxY": maxY,
      "data": timeList
    };

    Iterable pages = json.decode(response.body)["statistics"]["pages"];

    maxY = 0;
    xValue = 0;
    for (var val in pages) {
      pageList.add(FlSpot(xValue, val["pages"].toDouble()));

      if (val["pages"].toDouble() > maxY) maxY = val["pages"].toDouble();
      xValue += 1;
    }

    Map pageData = {
      "maxX": xValue.toDouble() - 1,
      "maxY": maxY,
      "data": pageList
    };

    Map returnData = {
      "time": timeData,
      "pages": pageData,
      "dateData": dateData,
    };

    return returnData;
  } on SocketException {
    print("error connecting to server");
  }
}

Future<Map> dayOfWeekStats(NavigatorArguments args, int duration) async {
  List<FlSpot> timeList = [];
  List<FlSpot> pageList = [];

  final response = await http
      .get("http://${args.url}:5000/users/${args.user.userID}/stats/weekly?time=$duration");

  Iterable i = json.decode(response.body)["stats"];

  double pagesY = 0;
  double timeY = 0;
  double xValue = 0;
  for (var a in i) {
    timeList.add(FlSpot(xValue, a["time"].toDouble()));
    pageList.add(FlSpot(xValue, a["pages"].toDouble()));

    if (a["pages"].toDouble() > pagesY) pagesY = a["pages"].toDouble();

    if (a["time"].toDouble() > timeY) timeY = a["time"].toDouble();

    xValue += 1;
  }

  Map returnMap = {
    "pages": {
      "maxY": pagesY, "data": pageList
    },
    "time": {
      "maxY": timeY, "data": timeList
    }
  };

  return returnMap;
}

Future<List<Book>> getSearchBooks(String search) async {
  print("searching");

  List<Book> bookList = [];

  try {
    if (search == "" || search == null) {
      return null;
    }

    final response = await http.get(
        "https://www.googleapis.com/books/v1/volumes?q=$search&maxResults=40&orderBy=relevance");

    Iterable i = json.decode(response.body)["items"];

    if (i == null) {
      return bookList;
    }

    bookList = List<Book>.from(i.map((model) => Book.fromSearchJson(model)));

    // for (Book a in bookList) {
    //   print("googleID: ${a.googleID}");
    //   print("isbn: ${a.ISBN}");
    //   print("selfLink: ${a.selfLink}");
    //   print(a.title);
    //   print("author: ${a.author}");
    //   print(a.description);
    //   print("total pages: ${a.totalPages}");
    //   print("thumbnail: ${a.thumbnail}");
    //   print(a.publishedDate);
    //   print("==========");
    // }

    return bookList;
  } on SocketException {
    Fluttertoast.showToast(msg: "Error Searching for Book");
    return null;
  }
}