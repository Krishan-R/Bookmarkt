import 'package:bookmarkt_flutter/drawer.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class homepage extends StatefulWidget {
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(title: Text("Home"),),
      drawer: myDrawer(args),
      // body: Text("homepage"),
      body: CachedNetworkImage(
        placeholder: (context, url) => CircularProgressIndicator(),
        imageUrl: "http://books.google.com/books/content?id=ba1XzQEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api",
      )
    );
  }
}

