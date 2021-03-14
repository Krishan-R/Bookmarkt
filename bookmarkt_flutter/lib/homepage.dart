import 'dart:convert';

import 'package:bookmarkt_flutter/Models/book.dart';
import 'package:bookmarkt_flutter/Models/bookshelf.dart';
import 'package:bookmarkt_flutter/Widgets/bookListView.dart';
import 'package:bookmarkt_flutter/drawer.dart';
import 'package:bookmarkt_flutter/library.dart';
import 'package:bookmarkt_flutter/navigatorArguments.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:http/http.dart' as http;

class homepage extends StatefulWidget {
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {

  callback() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    final NavigatorArguments args = ModalRoute.of(context).settings.arguments;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text("Dashboard"),
          ),
          drawer: myDrawer(args),
          // body: Text("homepage"),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView(
              children: [
                SizedBox(height:10),
                recentDashboard(args: args, callback: callback),
                Divider(thickness: 2),
                DayofWeek(args: args),
                SizedBox(height:10),
              ],
            ),
          )),
    );
  }
}

class recentDashboard extends StatefulWidget {
  NavigatorArguments args;
  Function callback;

  recentDashboard({Key key, this.args, this.callback}) : super(key: key);

  @override
  _recentDashboardState createState() => _recentDashboardState();
}

class _recentDashboardState extends State<recentDashboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recently Read",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(height: 5),
          FutureBuilder(
            future: getRecentBooks(widget.args),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Book> bookList = snapshot.data;

                if (bookList.length == 0) {
                  return Text("You've not read any books");
                }

                return Container(
                  height: 200,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Card(
                        child: InkWell(
                          onTap: () async {
                            List<Bookshelf> bookshelfList =
                                await getBookshelfList(widget.args);

                            Navigator.pushNamed(context, '/book',
                                    arguments: NavigatorArguments(
                                        widget.args.user, widget.args.url,
                                        bookshelfList: bookshelfList,
                                        book: bookList[index]))
                                .then((value) => widget.callback());
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 110,
                                height: 170,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Hero(
                                    tag: bookList[index].bookInstanceID,
                                    child: Image.network(
                                      "http://${widget.args.url}:5000/getThumbnail?path=${bookList[index].thumbnail}",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: 110,
                                  child: Text(
                                    bookList[index].title,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            },
          )
        ],
      ),
    );
  }
}

class DayofWeek extends StatefulWidget {
  NavigatorArguments args;

  DayofWeek({Key, key, this.args}) : super(key: key);

  @override
  _DayofWeekState createState() => _DayofWeekState();
}

class _DayofWeekState extends State<DayofWeek> {
  int graphDuration = 30;
  String graphFocus = "pages";
  List<bool> isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Daily Statistics",
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
            future: dayOfWeekStats(widget.args, graphDuration),
            builder: (context, snapshot) {
              if (snapshot.hasData) {

                if (snapshot.data["pages"]["maxY"] == 0) {
                  return Text("No Reading Data Found");
                }

                return Column(
                  children: [
                    SizedBox(height: 5),
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
                                dayOfWeek(snapshot.data, graphFocus),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}

Future<List<Book>> getRecentBooks(NavigatorArguments args) async {
  List<Book> bookList = [];

  final response = await http
      .get("http://${args.url}:5000/users/${args.user.userID}/recent");

  Iterable i = json.decode(response.body);

  for (var bookJson in i) {
    Book book = Book.fromJson(bookJson["data"]);
    bookList.add(book);
  }

  return bookList;
}

Future<Map> dayOfWeekStats(NavigatorArguments args, int duration) async {
  List<FlSpot> timeList = [];
  List<FlSpot> pageList = [];

  final response = await http
      .get("http://${args.url}:5000/users/${args.user.userID}/stats/weekly?time=$duration");

  Iterable i = json.decode(response.body)["stats"];

  double pagesY = 0;
  double timeY = 0;
  double xValue = 0;
  for (var a in i) {
    timeList.add(FlSpot(xValue, a["time"].toDouble()));
    pageList.add(FlSpot(xValue, a["pages"].toDouble()));

    if (a["pages"].toDouble() > pagesY) pagesY = a["pages"].toDouble();

    if (a["time"].toDouble() > timeY) timeY = a["time"].toDouble();

    xValue += 1;
  }

  Map returnMap = {
    "pages": {
      "maxY": pagesY, "data": pageList
    },
    "time": {
      "maxY": timeY, "data": timeList
    }
  };

  return returnMap;
}

LineChartData dayOfWeek(data, String focus) {
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
          switch (value.toInt()) {
            case 0:
              return "M";
            case 1:
              return "Tu";
            case 2:
              return "W";
            case 3:
              return "Th";
            case 4:
              return "F";
            case 5:
              return "Sa";
            case 6:
              return "Su";
          }

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
    maxX: 6,
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
