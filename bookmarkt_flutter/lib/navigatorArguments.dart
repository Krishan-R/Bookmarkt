import 'package:bookmarkt_flutter/Models/user.dart';

class NavigatorArguments {
  final User user;
  final String url;
  final int bookshelfID;
  final String bookshelfName;

  NavigatorArguments(this.user, this.url, {this.bookshelfID, this.bookshelfName});
}