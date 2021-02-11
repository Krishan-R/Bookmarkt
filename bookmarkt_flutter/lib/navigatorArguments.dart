import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Models/user.dart';
import 'package:bookmarkt_flutter/Models/bookshelf.dart';

class NavigatorArguments {
  final User user;
  final String url;
  final int bookshelfID;
  final String bookshelfName;
  final int bookInstanceID;
  final Book book;
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
}
