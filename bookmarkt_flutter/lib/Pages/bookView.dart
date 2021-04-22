import 'package:bookmarkt_flutter/Models/API%20requests.dart';
import 'package:bookmarkt_flutter/Models/readingSession.dart';
import 'package:bookmarkt_flutter/Widgets/readingSessionCard.dart';
import 'package:bookmarkt_flutter/Models/navigatorArguments.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';

class bookView extends StatefulWidget {
  @override
  _bookViewState createState() => _bookViewState();
}

class _bookViewState extends State<bookView> {
  NavigatorArguments args;

  callback(NavigatorArguments newArgs) {
    setState(() {
      args = newArgs;
    });
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == "Delete") {
                  final response = await http.delete(
                      "http://${args.url}:5000/users/${args.user.userID.toString()}/books/delete?bookInstanceID=${args.book.bookInstanceID}");

                  if (response.body == "deleted book instance") {
                    Navigator.pushReplacementNamed(context, "/allBooks",
                        arguments: args);
                  } else {
                    print(response.body);
                    Fluttertoast.showToast(msg: "Error deleting Book");
                  }
                } else if (value == "Edit") {
                  args.redirect = "edit";
                  Navigator.pushNamed(context, '/addBook', arguments: args)
                      .then((value) => setState(() {}));
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Edit', 'Delete'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView(
            children: [
              SizedBox(height: 10),
              bookHeader(args),
              SizedBox(height: 10),
              bookDescription(args: args),
              Divider(thickness: 2),
              readingSessionDetails(args: args),
              Divider(thickness: 2),
              readingPrediction(args: args),
              Divider(thickness: 2),
              lastReadingSession(args: args, callback: callback),
              Divider(thickness: 2),
              bookViewGraph(args: args),
              borrowing(args: args),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

Container bookHeader(args) {
  return Container(
    height: 197,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
            tag: args.book.bookInstanceID,
            child: Image.network(
                "http://${args.url}:5000/getThumbnail?path=${args.book.thumbnail}")),
        SizedBox(
          height: 20,
          width: 10,
        ),
        Expanded(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  args.book.title,
                  style: TextStyle(fontSize: 30),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "By " + args.book.author,
                  style: TextStyle(color: Colors.grey, fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  args.book.publishedDate ?? "",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                Container(
                  // color: Colors.grey,
                  child: RatingBar.builder(
                      initialRating: args.book.rating / 2,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 1),
                      itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                      onRatingUpdate: (rating) async {
                        args.book.rating = (rating * 2).toInt();

                        final response = await http.put(
                            "http://${args.url}:5000/users/${args.user.userID}/books/${args.book.bookInstanceID}/edit?rating=${rating * 2}");
                      }),
                ),
                SizedBox(
                  height: 5,
                ),
                FutureBuilder(
                  future: getBookshelfName(args, args.book.bookshelfID),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data == "")
                        return Text("No bookshelf",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic));

                      return InkWell(
                        onTap: () async {
                          args.bookshelfID = args.book.bookshelfID;

                          Navigator.pushNamed(context, "/bookshelf",
                              arguments: NavigatorArguments(args.user, args.url,
                                  bookshelfID: args.book.bookshelfID,
                                  bookshelfName: snapshot.data));
                        },
                        child: Text(
                          snapshot.data,
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return Text("No bookshelf");
                  },
                )
              ],
            ),
          ),
        )
      ],
    ),
  );
}

class readingSessionDetails extends StatefulWidget {
  NavigatorArguments args;

  readingSessionDetails({
    Key key,
    this.args,
  }) : super(key: key);

  @override
  _readingSessionDetailsState createState() => _readingSessionDetailsState();
}

class _readingSessionDetailsState extends State<readingSessionDetails> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pages Read:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    "${widget.args.book.currentPage}/${widget.args.book.totalPages}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              CircularPercentIndicator(
                radius: 50,
                lineWidth: 5,
                percent: (widget.args.book.currentPage /
                    widget.args.book.totalPages),
                center: Icon(Icons.book, color: Theme.of(context).primaryColor),
                progressColor: Colors.green,
                backgroundColor: Colors.grey,
              ),
              SizedBox(
                width: 50,
              ),
              CircularPercentIndicator(
                radius: 50,
                lineWidth: 5,
                percent: 1,
                center: Icon(Icons.watch_later,
                    color: Theme.of(context).primaryColor),
                progressColor: Colors.green,
                backgroundColor: Colors.grey,
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Time Read:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    "${widget.args.book.totalTimeRead} minutes",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FlatButton(
                onPressed: () {
                  addReadingSessionAlert(context, widget.args);
                },
                child: Text(
                  "Add Reading Session",
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).primaryColor),
            FlatButton(
              onPressed: () {
                Navigator.pushNamed(context, '/readingSession',
                        arguments: widget.args)
                    .then((value) => setState(() {}));
              },
              child: Text("Start Reading Session",
                  style: TextStyle(color: Colors.white)),
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ],
    );
  }
}

class bookDescription extends StatelessWidget {
  const bookDescription({
    Key key,
    @required this.args,
  }) : super(key: key);

  final NavigatorArguments args;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                content: SingleChildScrollView(
                  child: Text(
                    args.book.description,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                actions: [
                  FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
          },
        );
      },
      child: Text(
        args.book.description,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class bookViewGraph extends StatefulWidget {
  NavigatorArguments args;

  bookViewGraph({Key key, this.args}) : super(key: key);

  @override
  _bookViewGraphState createState() => _bookViewGraphState();
}

class _bookViewGraphState extends State<bookViewGraph> {
  int graphDuration = 30;
  String graphFocus = "pages";
  List<bool> isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "History",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(width: 5),
                Container(
                  height: 30,
                  child: ToggleButtons(
                    children: [Text("Pages"), Text("Time")],
                    isSelected: isSelected,
                    borderColor: Colors.white,
                    onPressed: (int index) {
                      setState(() {
                        isSelected[0] = !isSelected[0];
                        isSelected[1] = !isSelected[1];

                        if (isSelected[0])
                          graphFocus = "pages";
                        else
                          graphFocus = "time";
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("last"),
                Container(
                    width: 40,
                    child: TextFormField(
                      decoration: new InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      initialValue: graphDuration.toString(),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          // if 0, graphs are removed due to lack of data
                          if (int.parse(value) == 0) {
                            graphDuration = 1;
                          } else {
                            graphDuration = int.parse(value);
                          }
                        });
                      },
                    )),
                Text("days")
              ],
            ),
          ],
        ),
        FutureBuilder(
            future: getBookReadingStats(widget.args, graphDuration),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data[graphFocus]["maxY"] == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("No reading data found for this time period"),
                    ],
                  );
                }
                return Column(
                  children: [
                    Stack(
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 1.70,
                          child: Container(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(18),
                                ),
                                color: Color(0xff232d37)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  right: 18.0, left: 12.0, top: 24, bottom: 12),
                              child: LineChart(
                                historyGraphData(snapshot.data, graphFocus),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            }),
      ],
    );
  }
}

class readingPrediction extends StatefulWidget {
  NavigatorArguments args;

  readingPrediction({Key key, this.args}) : super(key: key);

  @override
  _readingPredictionState createState() => _readingPredictionState();
}

class _readingPredictionState extends State<readingPrediction> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: Card(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FutureBuilder(
                  future: getReadingSessions(
                      widget.args, widget.args.book.bookInstanceID),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<ReadingSession> sessionList = snapshot.data;
                      return Text(
                            ()  {

                          if (widget.args.book.completed) {
                            return "You have completed this book, Congratulations!";
                          } else if (widget.args.book.currentPage == 1 ||
                              widget.args.book.totalTimeRead == 0) {
                            return "Please add or start a reading session to find out estimate finish";
                          }

                          int pagesRead = 0;
                          for (var session in sessionList) {
                            pagesRead += session.pagesRead;
                          }

                          double pagesPerMinute = widget.args.book.totalTimeRead /
                              pagesRead;
                          int estimateTime = ((pagesPerMinute *
                              (widget.args.book.totalPages -
                                  widget.args.book.currentPage)))
                              .round();

                          return "Reading at a similar pace, you will finish this book in $estimateTime minutes";
                        }(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return CircularProgressIndicator();
                  },
                )),
          ),
        ),
        Visibility(
          visible: widget.args.book.totalTimeRead != 0,
          child: Container(
            width: double.infinity,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FutureBuilder(
                  future: getReadingSessions(
                      widget.args, widget.args.book.bookInstanceID),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<ReadingSession> sessionList = snapshot.data;
                      return Text(
                            ()  {

                          int pagesRead = 0;
                          for (var session in sessionList) {
                            pagesRead += session.pagesRead;
                          }

                          double secondsPerPage = (widget.args.book.totalTimeRead / pagesRead) * 60;

                          int minutes = (secondsPerPage / 60).floor();
                          int seconds = (secondsPerPage % 60).floor();
                          String sMinutes;
                          String sSeconds;

                          switch (minutes) {
                            case 1:
                              sMinutes = "${minutes.toString()} minute";
                              break;
                            case 0:
                              sMinutes = "";
                              break;
                            default:
                              sMinutes = "${minutes.toString()} minutes";
                          }

                          switch (seconds) {
                            case 1:
                              if (minutes == 0) {
                                sSeconds = "${seconds.toString().padLeft(2, "0")} second";
                              } else {
                                sSeconds = " and ${seconds.toString().padLeft(2, "0")} second";
                              }
                              break;
                            case 0:
                              sSeconds = "";
                              break;
                            default:
                              if (minutes == 0) {
                                sSeconds = "${seconds.toString().padLeft(2, "0")} seconds";
                              } else {
                                sSeconds = " and ${seconds.toString().padLeft(2, "0")} seconds";
                              }
                          }

                          return "Currently reading pace is $sMinutes$sSeconds per page";
                        }(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: ((widget.args.book.goalDate != null) &&
              !widget.args.book.completed),
          child: Container(
            width: double.infinity,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  () {
                    try {
                      Duration remainingDays =
                          widget.args.book.goalDate.difference(DateTime.now());
                      int pagesLeft = widget.args.book.totalPages -
                          widget.args.book.currentPage;

                      remainingDays += Duration(days: 1);

                      if (remainingDays.inDays == 0) {
                        return "You are on the last day!\n You need to read $pagesLeft pages today!";
                      } else if (remainingDays.isNegative) {
                        return "You missed your reading goal :(";
                      }

                      return "There are ${remainingDays.inDays} days left to hit your reading target!\nYou need to read ${(pagesLeft / remainingDays.inDays).ceil()} pages a day";
                    } catch (e) {
                      print(e);
                      print("^^expected error");
                    }
                    return "";
                  }(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class lastReadingSession extends StatefulWidget {
  NavigatorArguments args;
  Function callback;

  lastReadingSession({Key key, this.args, this.callback}) : super(key: key);

  @override
  _lastReadingSessionState createState() => _lastReadingSessionState();
}

class _lastReadingSessionState extends State<lastReadingSession> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getReadingSessions(widget.args, widget.args.book.bookInstanceID),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reading Sessions (${snapshot.data.length})",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            );
          }

          ReadingSession session = snapshot.data[0];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Reading Sessions (${snapshot.data.length})",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              GestureDetector(
                onTap: () {
                  widget.args.sessionList = snapshot.data;
                  Navigator.pushNamed(context, "/readingSessionHistory",
                          arguments: widget.args)
                      .then((value) {
                    // setState(() {});
                    widget.callback(widget.args);
                  });
                },
                child: readingSessionCard(session: session, args: widget.args),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }
}

class borrowing extends StatefulWidget {
  NavigatorArguments args;

  borrowing({Key key, this.args}) : super(key: key);

  @override
  _borrowingState createState() => _borrowingState();
}

class _borrowingState extends State<borrowing> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.args.book.borrowingFrom != null ||
          widget.args.book.borrowingTo != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(thickness: 2),
          Text(
            "Borrowing",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Container(
            width: double.infinity,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      () {
                        if (widget.args.book.borrowingFrom != null) {
                          return "You are borrowing this book from ${widget.args.book.borrowingFrom}";
                        } else if (widget.args.book.borrowingTo != null) {
                          return "You are lending this book to ${widget.args.book.borrowingTo}";
                        }

                        return "";
                      }(),
                      textAlign: TextAlign.center,
                    ),
                    Text(() {
                      if (widget.args.book.borrowingTime != null) {
                        return "It is due on ${widget.args.book.borrowingTime.year}-${widget.args.book.borrowingTime.month.toString().padLeft(2, '0')}-${widget.args.book.borrowingTime.day.toString().padLeft(2, '0')}";
                      } else {
                        return "There is no due date";
                      }
                    }())
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

addReadingSessionAlert(BuildContext context, NavigatorArguments args) {
  TextEditingController pagesReadController = new TextEditingController();
  DateTime selectedDate = DateTime.now();
  Duration duration = new Duration();
  bool completed = false;

  final _formKey = GlobalKey<FormState>();

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
        String pagesRead = pagesReadController.text;

        int timeRead = duration.inMinutes;
        args.book.totalTimeRead += timeRead;
        args.book.currentPage += int.parse(pagesRead);

        if (args.book.currentPage >= args.book.totalPages) {
          args.book.currentPage = args.book.totalPages;
          args.book.completed = true;
        }

        final response = await http.post(
            "http://${args.url}:5000/users/${args.user.userID}/books/${args.book.bookInstanceID}/read?pagesRead=${pagesRead}&timeRead=${timeRead}&date=${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}&updateProgress=true&completed=$completed");

        if (response.body == "added reading session") {
          Navigator.popUntil(context, ModalRoute.withName("/book"));
          Navigator.pushReplacementNamed(context, "/book", arguments: args);
        }
      }
    },
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text("Add Reading Session"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: pagesReadController,
                    decoration: InputDecoration(hintText: "Num. of pages read"),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty) return "Pages read cannot be empty";
                      if (int.parse(value) > args.book.totalPages)
                        return "Cannot be greater than total pages in book";
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: completed,
                        onChanged: (value) {
                          setState(() {
                            completed = !completed;
                          });
                        },
                      ),
                      Text(
                        "Completed?",
                        style: TextStyle(fontSize: 15),
                      )
                    ],
                  ),
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
                  FlatButton(
                      onPressed: () async {
                        DateTime picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now());
                        if (picked != null && picked != selectedDate)
                          setState(() {
                            selectedDate = picked;
                          });
                      },
                      child: Text(
                          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}"))
                ],
              ),
            ),
          ),
          actions: [
            cancelButton,
            continueButton,
          ],
        );
      });
    },
  );
}

LineChartData historyGraphData(data, focus) {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  return LineChartData(
    lineTouchData: LineTouchData(
      enabled: true,
    ),
    gridData: FlGridData(
      show: true,
      drawVerticalLine: true,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: const Color(0xff37434d),
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: const Color(0xff37434d),
          strokeWidth: 1,
        );
      },
    ),
    titlesData: FlTitlesData(
      show: true,
      bottomTitles: SideTitles(
        rotateAngle: 0,
        showTitles: true,
        reservedSize: 22,
        getTextStyles: (value) => const TextStyle(
            color: Color(0xff68737d),
            fontWeight: FontWeight.bold,
            fontSize: 14),
        getTitles: (value) {
          if (value % 7 == 0)
            return data["dateData"][value]
                .substring(5, data["dateData"][value].length)
                .replaceAll("-", "/");
          return '';
        },
        margin: 8,
      ),
      leftTitles: SideTitles(
        showTitles: true,
        getTextStyles: (value) => const TextStyle(
          color: Color(0xff67727d),
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        getTitles: (value) {
          if (data[focus]["maxY"] >= 200) {
            if (value % 50 == 0) return value.toInt().toString();
          } else if (data[focus]["maxY"] >= 100) {
            if (value % 25 == 0) return value.toInt().toString();
          } else if (data[focus]["maxY"] >= 50) {
            if (value % 25 == 0) return value.toInt().toString();
          } else if (data[focus]["maxY"] >= 10) {
            if (value % 10 == 0) return value.toInt().toString();
          } else {
            if (value % 5 == 0) return value.toInt().toString();
          }

          return '';
        },
        reservedSize: 28,
        margin: 12,
      ),
    ),
    borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1)),
    minX: 0,
    maxX: data[focus]["maxX"],
    minY: 0,
    maxY: data[focus]["maxY"],
    lineBarsData: [
      LineChartBarData(
        spots: data[focus]["data"],
        isCurved: false,
        colors: gradientColors,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: true,
          colors:
              gradientColors.map((color) => color.withOpacity(0.3)).toList(),
        ),
      ),
    ],
  );
}
