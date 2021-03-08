import 'dart:convert';
import 'dart:io';

import 'package:bookmarkt_flutter/navigatorArguments.dart';
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
  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;

    var data = 0;

    // List<FlSpot> graphData = getReadingStatistics(args);

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
                //todo go to edit book view
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
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            bookHeader(args),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return AlertDialog(
                        content: Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              args.book.description,
                              style: TextStyle(fontSize: 15),
                            ),
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
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              height: 100,
              // color: Colors.pink,
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
                        "${args.book.currentPage}/${args.book.totalPages}",
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
                    percent: (args.book.currentPage / args.book.totalPages),
                    center:
                        Icon(Icons.book, color: Theme.of(context).primaryColor),
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
                    center: Icon(Icons.watch,
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
                        "${args.book.totalTimeRead} minutes",
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
                      addReadingSessionAlert(context, args);
                    },
                    child: Text(
                      "Add Reading Session",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Theme.of(context).primaryColor),
                FlatButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/readingSession',
                            arguments: args)
                        .then((value) => setState(() {}));
                  },
                  child: Text("Start Reading Session",
                      style: TextStyle(color: Colors.white)),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),

            FutureBuilder(
                future: getReadingStatistics(args),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data["timeData"]["maxY"] == 0) {
                      return Text("Please read to show history");
                    }
                    return Column(
                      children: [
                        Text(
                          "Time Spent Reading - 30 Days",
                          textAlign: TextAlign.center,
                        ),
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
                                      right: 18.0,
                                      left: 12.0,
                                      top: 24,
                                      bottom: 12),
                                  child: LineChart(
                                    timeReadData(snapshot.data),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Pages Read - 30 Days",
                          textAlign: TextAlign.center,
                        ),
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
                                      right: 18.0,
                                      left: 12.0,
                                      top: 24,
                                      bottom: 12),
                                  child: LineChart(
                                    pagesReadData(snapshot.data),
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
        ),
      ),
    ));
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
            // color: Colors.red,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  args.book.title,
                  style: TextStyle(fontSize: 30),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "By " + args.book.author,
                  style: TextStyle(color: Colors.grey, fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
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
              ],
            ),
          ),
        )
      ],
    ),
  );
}

addReadingSessionAlert(BuildContext context, NavigatorArguments args) {
  TextEditingController pagesReadController = new TextEditingController();
  TextEditingController hoursController = new TextEditingController();
  TextEditingController minutesController = new TextEditingController();

  DateTime selectedDate = DateTime.now();

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

        int timeRead = (int.parse(hoursController.text) * 60) +
            int.parse(minutesController.text);
        args.book.totalTimeRead += timeRead;

        final response = await http.post(
            "http://${args.url}:5000/users/${args.user.userID}/books/${args.book.bookInstanceID}/read?pagesRead=${pagesRead}&timeRead=${timeRead}&date=${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}&updateProgress=false");

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
                    Text(
                      "(Will not update book progress)",
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    TextFormField(
                      controller: pagesReadController,
                      decoration:
                          InputDecoration(hintText: "Num. of pages read"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value.isEmpty) return "Pages read cannot be empty";
                        if (int.parse(value) > args.book.totalPages)
                          return "Cannot be greater than total pages in book";
                        return null;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          padding: EdgeInsets.zero,
                          child: TextFormField(
                            controller: hoursController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                                hintText: "HH",
                                contentPadding: EdgeInsets.zero),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              new LengthLimitingTextInputFormatter(2)
                            ],
                            validator: (value) {
                              if (value.isEmpty) return "Cannot be empty";
                              return null;
                            },
                          ),
                        ),
                        Text(":"),
                        Container(
                          width: 60,
                          padding: EdgeInsets.zero,
                          child: TextFormField(
                            controller: minutesController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(hintText: "MM"),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              new LengthLimitingTextInputFormatter(2)
                            ],
                            validator: (value) {
                              if (value.isEmpty) return "Cannot be empty";
                              if (int.parse(value) >= 60) return "Too Large";
                              return null;
                            },
                          ),
                        )
                      ],
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
      });
}

LineChartData timeReadData(data) {
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
          if (data["timeData"]["maxY"] >= 200) {
            if (value % 50 == 0) return value.toInt().toString();
          } else if (data["timeData"]["maxY"] >= 100) {
            if (value % 25 == 0) return value.toInt().toString();
          } else if (data["timeData"]["maxY"] >= 50) {
            if (value % 25 == 0) return value.toInt().toString();
          } else if (data["timeData"]["maxY"] >= 10) {
            if (value % 10 == 0) return value.toInt().toString();
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
    maxX: data["timeData"]["maxX"],
    minY: 0,
    maxY: data["timeData"]["maxY"],
    lineBarsData: [
      LineChartBarData(
        spots: data["timeData"]["data"],
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

LineChartData pagesReadData(data) {
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
          if (data["pageData"]["maxY"] >= 200) {
            if (value % 50 == 0) return value.toInt().toString();
          } else if (data["pageData"]["maxY"] >= 100) {
            if (value % 25 == 0) return value.toInt().toString();
          } else if (data["pageData"]["maxY"] >= 50) {
            if (value % 25 == 0) return value.toInt().toString();
          } else if (data["pageData"]["maxY"] >= 10) {
            if (value % 10 == 0) return value.toInt().toString();
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
    maxX: data["pageData"]["maxX"],
    minY: 0,
    maxY: data["pageData"]["maxY"],
    lineBarsData: [
      LineChartBarData(
        spots: data["pageData"]["data"],
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

Future<Map> getReadingStatistics(NavigatorArguments args) async {
  List<FlSpot> timeList = [];
  List<FlSpot> pageList = [];
  Map dateData = {};

  try {
    final response = await http.get(
        "http://${args.url}:5000/users/${args.user.userID}/books/${args.book.bookInstanceID}/stats?time=30");

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
      "timeData": timeData,
      "dateData": dateData,
      "pageData": pageData
    };
    
    return returnData;
  } on SocketException {
    print("error connecting to server");
  }
}
