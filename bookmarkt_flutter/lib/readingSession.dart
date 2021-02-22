import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/allBooks.dart';
import 'package:bookmarkt_flutter/drawer.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class readingSession extends StatefulWidget {
  @override
  _readingSessionState createState() => _readingSessionState();
}

class _readingSessionState extends State<readingSession> {
  Duration sessionDuration = new Duration();

  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute
        .of(context)
        .settings
        .arguments;

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          print("prevented pop");
          // todo confirm exit reading session
          return true;
        },
        child: Scaffold(
          // backgroundColor: Colors.grey,
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Start Reading Session for",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        args.book.title,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      FlatButton(
                        child: Text("Untimed",
                            style: TextStyle(color: Colors.white)),
                        color: Theme
                            .of(context)
                            .primaryColor,
                        onPressed: () {
                          sessionDuration = Duration(seconds: 0);
                        },
                      ),
                      FlatButton(
                        child: Text("Set Duration",
                            style: TextStyle(color: Colors.white)),
                        color: Theme
                            .of(context)
                            .primaryColor,
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext builder) {
                                return Container(
                                  height: MediaQuery
                                      .of(context)
                                      .copyWith()
                                      .size
                                      .height /
                                      3,
                                  child: CupertinoTimerPicker(
                                    mode: CupertinoTimerPickerMode.hm,
                                    initialTimerDuration: sessionDuration,
                                    onTimerDurationChanged: (value) {
                                      setState(() {
                                        sessionDuration = value;
                                      });
                                    },
                                  ),
                                );
                              });
                        },
                      ),
                    ],
                  ),
                  FlatButton(
                    child: Text("START", style: TextStyle(color: Colors.white)),
                    color: Theme
                        .of(context)
                        .primaryColor,
                    onPressed: () {
                      if (sessionDuration.inMinutes > 0) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    readingSessionCountdown()));
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                readingSessionTimer(
                                  args: args,
                                ),
                          ),
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class readingSessionTimer extends StatefulWidget {
  final NavigatorArguments args;

  const readingSessionTimer({Key key, this.args}) : super(key: key);

  @override
  _readingSessionTimerState createState() => _readingSessionTimerState();
}

class _readingSessionTimerState extends State<readingSessionTimer> {
  final StopWatchTimer stopWatchTimer = StopWatchTimer();
  bool paused = false;
  String pauseResume = "Pause";

  @override
  Widget build(BuildContext context) {
    if (paused) {
      stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    } else {
      stopWatchTimer.onExecute.add(StopWatchExecute.start);
    }

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          bool result = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Are you sure you want to leave this session?"),
                  actions: [
                    FlatButton(
                      child: Text("No"),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    FlatButton(
                      child: Text("Yes"),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                );
              });

          if (result) stopWatchTimer.onExecute.add(StopWatchExecute.stop);
          return result;
        },
        child: Scaffold(
          // backgroundColor: Colors.grey,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.args.book.title,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.args.book.author,
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
                SizedBox(
                  height: 20,
                ),
                StreamBuilder<int>(
                  stream: stopWatchTimer.secondTime,
                  initialData: 0,
                  builder: (context, snap) {
                    final value = snap.data;
                    String hours = ((value / (60 * 60)) % 60)
                        .floor()
                        .toString()
                        .padLeft(2, '0');

                    String mins =
                    ((value / 60) % 60).floor().toString().padLeft(2, '0');

                    String seconds =
                    (value % 60).floor().toString().padLeft(2, '0');

                    // print(value);

                    return CircularPercentIndicator(
                      circularStrokeCap: CircularStrokeCap.round,
                      radius: 300,
                      lineWidth: 10,
                      percent: 1,
                      center: Text(
                        "$hours:$mins:$seconds",
                        style: TextStyle(fontSize: 30),
                      ),
                      backgroundColor: Colors.grey,
                      progressColor: Colors.purple,
                    );
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      color: Theme
                          .of(context)
                          .primaryColor,
                      onPressed: () async {

                        bool result = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Are you sure you want to leave this session?"),
                                actions: [
                                  FlatButton(
                                    child: Text("No"),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("Yes"),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ],
                              );
                            });

                        if (result) Navigator.pop(context);
                      },
                      child:
                      Text("Cancel", style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    FlatButton(
                      color: Theme
                          .of(context)
                          .primaryColor,
                      onPressed: () {
                        //todo pause
                        if (paused) {
                          stopWatchTimer.onExecute.add(StopWatchExecute.start);
                          setState(() {
                            pauseResume = "Pause";
                          });
                        } else {
                          stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                          setState(() {
                            pauseResume = "Resume";
                          });
                        }
                        paused = !paused;
                      },
                      child: Text(pauseResume,
                          style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    FlatButton(
                      color: Theme
                          .of(context)
                          .primaryColor,
                      child:
                      Text("Finish", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        int timeRead = stopWatchTimer.minuteTime.value;

                        final _formKey = GlobalKey<FormState>();
                        bool completed = false;
                        TextEditingController currentPageController =
                        new TextEditingController();

                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      title: Text("Finish Reading Session"),
                                      content: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 200,
                                              child: TextFormField(
                                                controller: currentPageController,
                                                keyboardType: TextInputType
                                                    .number,
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                    hintText: "Current Page"),
                                                validator: (value) {
                                                  if (value.isEmpty)
                                                    return "Cannot be empty";
                                                  if (int.parse(value) -
                                                      widget.args.book
                                                          .currentPage <
                                                      0) {
                                                    return "You have already read this page";
                                                  }
                                                  if (int.parse(value) >
                                                      widget.args.book
                                                          .totalPages) {
                                                    return "This book only has ${widget
                                                        .args.book
                                                        .totalPages} pages";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                Checkbox(
                                                    value: completed,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        completed = value;
                                                      });
                                                    }),
                                                Text("Completed book")
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        FlatButton(
                                          child: Text("Discard"),
                                          onPressed: () async {

                                            bool result = await showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Are you sure you want to leave this session?"),
                                                    actions: [
                                                      FlatButton(
                                                        child: Text("No"),
                                                        onPressed: () {
                                                          Navigator.of(context).pop(false);
                                                        },
                                                      ),
                                                      FlatButton(
                                                        child: Text("Yes"),
                                                        onPressed: () {
                                                          Navigator.of(context).pop(true);
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                });

                                            if (result) {
                                              Navigator.popUntil(context, ModalRoute.withName('/book'));
                                            }
                                          },
                                        ),
                                        FlatButton(
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        FlatButton(
                                          child: Text("Add"),
                                          onPressed: () async {
                                            if (_formKey.currentState
                                                .validate()) {
                                              String pagesRead =
                                                  "&pagesRead=${int.parse(
                                                  currentPageController.text) -
                                                  widget.args.book
                                                      .currentPage}";
                                              String completedString = "";
                                              if (completed) {
                                                completedString =
                                                "&completed=True";
                                              }

                                              final response = await http.post(
                                                  "http://${widget.args
                                                      .url}:5000/users/${widget
                                                      .args.user
                                                      .userID}/books/${widget
                                                      .args.book
                                                      .bookInstanceID}/read?timeRead=$timeRead$completedString$pagesRead");

                                              print(response.body);

                                              if (response.body ==
                                                  "added reading session") {
                                                widget.args.book
                                                    .totalTimeRead +=
                                                    timeRead;
                                                widget.args.book.currentPage =
                                                    int.parse(
                                                        currentPageController
                                                            .text);

                                                Navigator.popUntil(context,
                                                    ModalRoute.withName(
                                                        '/book'));
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg:
                                                    "Error adding reading session");
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            });
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class readingSessionCountdown extends StatefulWidget {
  @override
  _readingSessionCountdownState createState() =>
      _readingSessionCountdownState();
}

class _readingSessionCountdownState extends State<readingSessionCountdown> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          bool result = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Are you sure you want to leave this session?"),
                  actions: [
                    FlatButton(
                      child: Text("No"),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    FlatButton(
                      child: Text("Yes"),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                );
              });

          return result;
        },
        child: Scaffold(
          body: Column(
            children: [Text("countdown")],
          ),
        ),
      ),
    );
  }
}
