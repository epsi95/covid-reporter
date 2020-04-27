import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';

class ReportedCaseCard extends StatelessWidget {
  final List<dynamic> data; // [{}, {}, {}]
  final int reportedBy; // 0-all, 1-me only 2 - only others
  final int sortByPoints; // 0 - highest to lowest
  final Function plusOneCallback;
  final Function deleteOneCallback;
  ReportedCaseCard(
      {@required this.data,
      this.reportedBy,
      this.sortByPoints,
      this.plusOneCallback,
      this.deleteOneCallback});

  List<Widget> getCustomCard(List<dynamic> pl) {
    List<Widget> c = [];
    for (dynamic _data in pl) {
      c.add(CustomCard(
        points: _data["points"],
        distance: double.parse(_data["d_from_u"]),
        reportedDate: _data["reported_date"],
        note: _data["note"],
        canCite: _data["can_cite"] == "0" ? false : true,
        patientAge: _data["age_group"],
        gender: _data["sex"],
        canDelete: _data["can_delete"] == "0" ? false : true,
        caseId: _data["case_id"].toString(),
        plusOneCallback: plusOneCallback,
        deleteOneCallback: deleteOneCallback,
      ));
    }
    c.add(SizedBox(
      height: 100.0,
    ));
    return c;
  }

  List<Widget> getSortedCustomCard(List<dynamic> pl) {
    //filter 1
    List<dynamic> truncatedList = [];
    if (reportedBy == 0) {
      truncatedList = data;
    } else if (reportedBy == 1) {
      //only me
      for (dynamic each in pl) {
        if (each["can_delete"] == "1") {
          truncatedList.add(each);
        }
      }
    } else if (reportedBy == 2) {
      //only others
      for (dynamic each in pl) {
        if (each["can_delete"] == "0") {
          truncatedList.add(each);
        }
      }
    }

    //now we will apply second filter
    if (sortByPoints == 0) {
      //already sorted from sever good to go
      return getCustomCard(truncatedList);
    } else {
      truncatedList = truncatedList.reversed.toList();
      return getCustomCard(truncatedList);
    }
  }

  @override
  Widget build(BuildContext context) {
//    if (getSortedCustomCard().length == 0) {
//      print("no data");
//    }
//    print("custom card length");
//    print(getSortedCustomCard());
//    print("stless widget");
//    print(data);
//    print(getSortedCustomCard(data).length);
    return SingleChildScrollView(
      child: Column(
        children: reportedBy == 0 && sortByPoints == 0
            ? getCustomCard(data)
            : getSortedCustomCard(data).length == 1
                ? [
                    Text(
                      "nothing to show",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueGrey),
                    )
                  ]
                : getSortedCustomCard(data),
      ),
    );
  }
}

class CustomCard extends StatefulWidget {
  final int points;
  final double distance;
  final String reportedDate;
  final String note;
  final bool canCite;
  final bool canDelete;
  final String patientAge;
  final String gender;
  final String caseId;
  final Function plusOneCallback;
  final Function deleteOneCallback;

  CustomCard(
      {this.points,
      this.distance,
      this.reportedDate,
      this.note,
      this.canCite,
      this.patientAge,
      this.gender,
      this.canDelete,
      this.caseId,
      this.plusOneCallback,
      this.deleteOneCallback});

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  final TextStyle headerStyle = TextStyle(
      fontWeight: FontWeight.normal, color: Colors.white70, fontSize: 16.0);

  final TextStyle infoStyle = TextStyle(
      fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16.0);

  bool _selected = false;
  double containerHeight = 400.0;
  double containerWidth = 400;
  bool _isCompressed = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    containerWidth = width;
    return GestureDetector(
      onLongPressStart: (_) {
        _selected = !_selected;
        setState(() {});
      },
      onLongPressUp: () {
        _selected = !_selected;
        setState(() {});
      },
      child: AnimatedContainer(
        curve: Curves.easeOut,
        width: _selected ? containerWidth * 0.95 : containerWidth,
        height: _selected ? containerHeight * 0.95 : containerHeight,
        duration: Duration(milliseconds: 400),
        child: _isCompressed
            ? null
            : Card(
                color: _selected
                    ? Color(0xFF6200EE)
                    : Color(0xFF6200EE).withOpacity(
                        0.7), //Colors.redAccent.withOpacity([1.0, points / 5].reduce(min)),
                child: Container(
//          width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.flag,
                                color: Colors.white,
                              ),
                              Text(
                                "  Case ID",
                                style: headerStyle,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text("CASE-" + widget.caseId, style: infoStyle)
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.people,
                                color: Colors.white,
                              ),
                              Text(
                                "  No. of people reported",
                                style: headerStyle,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text("${widget.points}", style: infoStyle)
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.near_me,
                                color: Colors.white,
                              ),
                              Text(
                                "  within around ${widget.distance.floor()} m. from you",
                                style: headerStyle,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                              ),
                              Text(
                                "  Reported Date",
                                style: headerStyle,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(widget.reportedDate, style: infoStyle)
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                              Text(
                                "  Patient Sex & Age-group",
                                style: headerStyle,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                  "  " +
                                      widget.gender +
                                      "  " +
                                      widget.patientAge,
                                  style: infoStyle)
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            widget.canCite ? "" : "👍  Reported by you",
                            style: headerStyle,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "Description",
                            style: headerStyle,
                          ),
                          Container(
                            height: 50.0,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: SingleChildScrollView(
                              child: Text(
                                widget.note,
                                style: infoStyle,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.deepPurple,
                                child: IconButton(
                                  icon: Icon(Icons.plus_one),
                                  onPressed: widget.canCite
                                      ? () {
                                          widget.plusOneCallback(widget.caseId);
                                        }
                                      : null,
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.deepPurple,
                                child: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: widget.canDelete
                                      ? () async {
                                          _isCompressed = true;
                                          containerHeight = 0;
                                          setState(() {});
                                          String response = await widget
                                              .deleteOneCallback(widget.caseId);
                                          if (true) {
                                            containerHeight = 400;
                                            Timer(Duration(milliseconds: 450),
                                                () {
                                              setState(() {});
                                              _isCompressed = false;
                                            });
                                          }
                                        }
                                      : null,
                                ),
                              ),
                            ],
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
