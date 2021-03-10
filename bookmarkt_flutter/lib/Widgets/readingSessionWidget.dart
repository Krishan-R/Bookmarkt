import 'package:bookmarkt_flutter/Models/readingSession.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class readingSessionWidget extends StatelessWidget {
  const readingSessionWidget({
    Key key,
    @required this.session,
  }) : super(key: key);

  final ReadingSession session;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                  () {
                List<String> months = [
                  "January",
                  "February",
                  "March",
                  "April",
                  "May",
                  "June",
                  "July",
                  "August",
                  "September",
                  "October",
                  "November",
                  "December"
                ];
                return "${session.date.day.toString().padLeft(2, '0')} ${months[session.date.month - 1]} ${session.date.year}";
              }(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text("Pages Read",
                        style: TextStyle(fontSize: 15)),
                    Text("${session.pagesRead} pages"),
                  ],
                ),
                Column(
                  children: [
                    Text("Time Read", style: TextStyle(fontSize: 15)),
                    Text("${session.timeRead} mins"),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}