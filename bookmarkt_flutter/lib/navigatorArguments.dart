import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Models/user.dart';
import 'package:bookmarkt_flutter/Models/bookshelf.dart';

class NavigatorArguments {
  final User user;
  final String url;
  int bookshelfID;
  String bookshelfName;
  int bookInstanceID;
  Book book;
  List<Bookshelf> bookshelfList;
  String redirect;

  NavigatorArguments(
      this.user,
      this.url,
      {this.bookshelfID,
      this.bookshelfName,
      this.bookInstanceID,
      this.book,
      this.bookshelfList,
      this.redirect});

  void printStuff() {
    print("=====");
    print("username: ${user.username}");
    print("url: $url");
    print("bookshelfID: $bookshelfID");
    print("bookshelfName: $bookshelfName");
    print("bookInstanceID: $bookInstanceID");
    print("book.title: ${book}");

    print("BookshelfList: ");
    if (bookshelfList != null && bookshelfList.isNotEmpty) {
      for (Bookshelf bookshelf in bookshelfList) {
        print(bookshelf.name);
      }
    }

    print("redirect: $redirect");
    print("=====");

  }
}
