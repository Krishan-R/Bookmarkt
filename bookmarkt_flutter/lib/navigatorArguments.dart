import 'package:bookmarkt_flutter/Models/user.dart';

class NavigatorArguments {
  final User user;
  final String url;
  final int bookshelfID;

  NavigatorArguments(this.user, this.url, {this.bookshelfID});
}