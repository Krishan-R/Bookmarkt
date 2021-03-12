import 'package:bookmarkt_flutter/Models/readingSession.dart';
import 'package:bookmarkt_flutter/Widgets/readingSessionCard.dart';
import 'package:bookmarkt_flutter/bookView.dart';
import 'package:bookmarkt_flutter/drawer.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class readingSessionHistory extends StatefulWidget {
  @override
  _readingSessionHistoryState createState() => _readingSessionHistoryState();
}

class _readingSessionHistoryState extends State<readingSessionHistory> {
  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Reading Sessions"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            addReadingSessionAlert(context, args);
          },
          child: Icon(Icons.add),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: args.sessionList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      readingSessionActions(context, setState, args,
                          args.sessionList[index], index);
                    },
                    child: readingSessionCard(
                        session: args.sessionList[index], args: args));
              },
            ),
          ),
        ),
      ),
    );
  }
}

class allSessionHistory extends StatefulWidget {
  @override
  _allSessionHistoryState createState() => _allSessionHistoryState();
}

class _allSessionHistoryState extends State<allSessionHistory> {
  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Reading Sessions"),
        ),
        drawer: myDrawer(args),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: args.sessionList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      readingSessionActions(context, setState, args,
                          args.sessionList[index], index);
                    },
                    child: readingSessionCard(
                        session: args.sessionList[index], args: args));
              },
            ),
          ),
        ),
      ),
    );
  }
}

readingSessionActions(BuildContext context, setState, NavigatorArguments args,
    ReadingSession session, int index) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Edit Reading Session"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlatButton(
          child: Text("Edit"),
          onPressed: () async {
            args.readingSession = session;
            Navigator.pushNamed(context, "/editReadingSession", arguments: args)
                .then((value) {
              setState(() {});
              Navigator.pop(context);
            });
          },
        ),
        FlatButton(
          child: Text("Delete"),
          onPressed: () async {
            final response = await http.delete(
                "http://${args.url}:5000/users/${args.user.userID}/readingSessions/delete?readingSessionID=${session.readingSessionID}");

            if (response.body == "Deleted reading session") {
              args.book.totalTimeRead -= session.timeRead;
              args.book.currentPage -= session.pagesRead;

              if (args.book.currentPage < 0) args.book.currentPage = 0;

              args.sessionList.removeAt(index);

              if (args.sessionList.length == 0) {
                Navigator.popUntil(context, ModalRoute.withName("/book"));
              } else {
                Navigator.pop(context);
                Navigator.popAndPushNamed(context, '/readingSessionHistory',
                    arguments: args);
              }
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

class editReadingSession extends StatefulWidget {
  @override
  _editReadingSessionState createState() => _editReadingSessionState();
}

class _editReadingSessionState extends State<editReadingSession> {
  final _formKey = GlobalKey<FormState>();
  bool firstInit = true;
  int oldTime;
  Duration duration = new Duration();

  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;

    if (firstInit) {
      oldTime = args.readingSession.timeRead;
      duration = Duration(minutes: args.readingSession.timeRead);
      firstInit = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Reading Session"),
        actions: [
          FlatButton(
            child: Text("Save"),
            onPressed: () async {
              args.book.totalTimeRead +=
                  (duration.inMinutes - oldTime);

              args.readingSession.timeRead = duration.inMinutes;

              final response = await http.put(
                  "http://${args.url}:5000/users/${args.user.userID}/readingSessions/edit?readingSessionID=${args.readingSession.readingSessionID}&pagesRead=${args.readingSession.pagesRead}&timeRead=${args.readingSession.timeRead}&date=${args.readingSession.date.year}-${args.readingSession.date.month}-${args.readingSession.date.day}");

              if (response.body == "Successfully edited reading session") {
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pages Read:"),
              TextFormField(
                initialValue: args.readingSession.pagesRead.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  args.readingSession.pagesRead = int.parse(value);
                },
              ),
              SizedBox(height: 10),
              Text("Time Read:"),
              FlatButton(
                child: Text(
                    "${duration.inHours.toString().padLeft(2, '0')} : ${(duration.inMinutes % 60).toString().padLeft(2, '0')}"),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext builder) {
                      return Container(
                        height:
                        MediaQuery.of(context).copyWith().size.height /
                            3,
                        child: CupertinoTimerPicker(
                          mode: CupertinoTimerPickerMode.hm,
                          initialTimerDuration: duration,
                          onTimerDurationChanged: (value) {
                            setState(() {
                              duration = value;
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 10),
              Text("Date:"),
              FlatButton(
                  onPressed: () async {
                    DateTime picked = await showDatePicker(
                        context: context,
                        initialDate: args.readingSession.date,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now());
                    if (picked != null && picked != args.readingSession.date)
                      setState(() {
                        args.readingSession.date = picked;
                      });
                  },
                  child: Text(
                      "${args.readingSession.date.year}-${args.readingSession.date.month.toString().padLeft(2, '0')}-${args.readingSession.date.day.toString().padLeft(2, '0')}"))
            ],
          ),
        ),
      )),
    );
  }
}
