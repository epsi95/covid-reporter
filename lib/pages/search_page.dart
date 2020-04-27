import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert' as convert;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:covid_reporter/constants/constants.dart';
import 'package:covid_reporter/utils/get_user_location.dart';
import 'package:covid_reporter/components/reported_cases_card.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:covid_reporter/components/search_report_page_component.dart';

class SearchPage extends StatefulWidget {
  final String userID;
  final Function callbackFunction;
  SearchPage({@required this.userID, this.callbackFunction});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _userID;
  Function _showSnackBar;
  int _whatToShow = 0; //0-nothing to show 1-list 2-map
  int _defaultSearchDistance = 200;
  IconData _iconData = Icons.list;
  bool _isModalProgressHudActive = false;
  List<dynamic> _pageFeedData;
  String _fabText = "Refresh 200m.";
  LocationData _lastReportedUserLocation;

  int _lastSuccessfulSearchDistance;

  //showing constrain
  int _reportedBy = 0; // 0-all, 1-me only 2 - only others
  int _sortByPoints = 0; // 0 - highest to lowest

  void _toggleIconData() {
    _iconData = _iconData == Icons.list ? Icons.map : Icons.list;
    setState(() {});
  }

  void _toggleModalProgressHud() {
    print("toggling from " +
        _isModalProgressHudActive.toString() +
        " to " +
        (!_isModalProgressHudActive).toString());
    setState(() {
      _isModalProgressHudActive = !_isModalProgressHudActive;
    });
  }

  void _toggleWhatToShow() {
    setState(() {
      _whatToShow = _whatToShow == 1 ? 2 : 1;
    });
  }

  void _intelligentFetchReportedCasesData() {
    if (_lastSuccessfulSearchDistance == _defaultSearchDistance) {
      setState(() {});
    } else {
      _fetchReportedCasesData();
    }
  }

  Future<LocationData> _initializeLocation() async {
    GetUserLocation getUserLocation = GetUserLocation();
    var location = await getUserLocation.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      _lastReportedUserLocation = currentLocation;
    });
    return location.getLocation();
  }

  void _plusOneCallback(String caseID) {
    print(caseID);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: const Text(kReportAgreement),
          actions: <Widget>[
            RaisedButton(
              child: Text('Ok'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  _toggleModalProgressHud();
                  var response = await http.post(kCiteReportedCase,
                      body: convert.json.encode({
                        "auth_key": kAuthKey,
                        "encrypted_user_id": _userID,
                        "case_id": caseID
                      }),
                      headers: {
                        'Content-Type': 'application/json'
                      }).timeout(Duration(seconds: 10));
                  print(response.body);
                  var data = convert.jsonDecode(response.body)["data"];
                  if (data["response"] == "success") {
                    _toggleModalProgressHud();
                    _showSnackBar("conformation successful, updating list...");
                    await _fetchReportedCasesData();
                    return ("success");
                  } else {
                    _toggleModalProgressHud();
                    _showSnackBar("unable to confirm");
                    return ("error");
                  }
                } catch (e) {
                  _toggleModalProgressHud();
                  print(e);
                  _showSnackBar("can't connect to internet.");
                  return ("error");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> _deleteReportedCase(String caseID) async {
    _toggleModalProgressHud();
    try {
      var response = await http.post(kDeleteReportedCase,
          body: convert.json.encode({
            "auth_key": kAuthKey,
            "encrypted_user_id": _userID,
            "case_id": caseID
          }),
          headers: {
            'Content-Type': 'application/json'
          }).timeout(Duration(seconds: 10));
//        print(response.body);
      var data = convert.jsonDecode(response.body)["data"];
      if (data["response"] == "success") {
        _toggleModalProgressHud();
        _showSnackBar("delete successful, updating list...");
        await _fetchReportedCasesData();
        return ("success");
      } else {
        _toggleModalProgressHud();
        _showSnackBar("unable to delete");
        return ("error");
      }
    } catch (e) {
      _toggleModalProgressHud();
      print(e);
      _showSnackBar("can't connect to internet.");
      return ("error");
    }
  }

  Future<bool> _fetchReportedCasesData() async {
    print(_defaultSearchDistance);
    print(
        "last reported user location  " + _lastReportedUserLocation.toString());
//    if(_lastReportedUserLocation == null && lcData != null){
//      _lastReportedUserLocation = lcData;
//    }
    _toggleModalProgressHud();
    var locationData = _lastReportedUserLocation;
    if (locationData == null) {
      _toggleModalProgressHud();
      _showSnackBar("can't fetch location data");
      return false;
    } else {
      try {
        var response = await http.post(kGetReportedCasesUrl,
            body: convert.json.encode({
              "auth_key": kAuthKey,
              "encrypted_id": _userID,
              "d": _defaultSearchDistance.toString(),
              "my_lat": locationData.latitude.toString(),
              "my_lon": locationData.longitude.toString()
            }),
            headers: {
              'Content-Type': 'application/json'
            }).timeout(Duration(seconds: 10));
        print(response.body);
        var data = convert.jsonDecode(response.body)["data"];
        if (data["response"] == "success") {
          _lastSuccessfulSearchDistance = _defaultSearchDistance;
          _toggleModalProgressHud();
          if (data["message"].length > 0) {
            _pageFeedData = data["message"];
            _whatToShow = _iconData == Icons.list ? 1 : 2;
            _fabText = "Refresh " + _defaultSearchDistance.toString() + "m.";
            setState(() {});
            return true;
//          print(_pageFeedData);
          } else {
            _whatToShow = 0;
            setState(() {});
            return true;
          }
        } else {
          _toggleModalProgressHud();
          _showSnackBar("unable to get data");
          return false;
        }
      } catch (e) {
        _toggleModalProgressHud();
        print(e);
        _showSnackBar("can't connect to internet.");
        return false;
      }
    }
  }

  void _firstLocationThenData() {
    _toggleModalProgressHud();
    _initializeLocation().then((locationData) {
      _lastReportedUserLocation = locationData;
      _toggleModalProgressHud();
      _fetchReportedCasesData();
    });
  }

  @override
  void initState() {
    _userID = widget.userID;
    _showSnackBar = widget.callbackFunction;
    _firstLocationThenData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("%%");
    print(_reportedBy);
    print(_sortByPoints);
    return ModalProgressHUD(
      inAsyncCall: _isModalProgressHudActive,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _fetchReportedCasesData();
          },
          label: Text(_fabText),
          icon: Icon(
            Icons.refresh,
            color: Colors.white,
          ),
          backgroundColor: Color(0xFF6200EE),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            //under-widget it can be "nothing to show or list ot map
            (_whatToShow == 0
                ? Center(
                    child: Text(
                      "nothing to show",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueGrey),
                    ),
                  )
                : _whatToShow == 1
                    ? Center(
                        child: ReportedCaseCard(
                          data: _pageFeedData,
                          sortByPoints: _sortByPoints,
                          reportedBy: _reportedBy,
                          deleteOneCallback: _deleteReportedCase,
                          plusOneCallback: _plusOneCallback,
                        ),
                      )
                    : SearchReportMap(
                        data: _pageFeedData,
                        location: _lastReportedUserLocation,
                        searchDistance: _lastSuccessfulSearchDistance,
                      )),
            //over widget which gives control like select distance and underneath type and refresh
            Positioned(
              top: 20.0,
              right: 20.0,
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Color(0xFF6200EE),
                    child: IconButton(
                      onPressed: () {
                        if (_whatToShow == 0) {
                          _showSnackBar(
                              "np data to show, select different distance range to try refreshing the page");
                        } else {
                          _toggleIconData();
                          setState(() {
                            _toggleWhatToShow();
                          });
                        }
                      },
                      icon: Icon(
                        _iconData,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  CircleAvatar(
                    backgroundColor: Color(0xFF6200EE),
                    child: IconButton(
                      onPressed: () {
                        // flutter defined function
                        showDialog(
                          context: context,
                          builder: (context) {
                            int groupValueReportedBy = _reportedBy;
                            int groupValueSortBy = _sortByPoints;
                            int distance = _defaultSearchDistance;
                            TextStyle headerStyle = TextStyle(
                              fontWeight: FontWeight.w700,
                            );
                            void _handleReportedByRadioButton(int index) {
                              _reportedBy = index;
                              groupValueReportedBy = index;
                            }

                            void _handleSortByRadioButton(int index) {
                              _sortByPoints = index;
                              groupValueSortBy = index;
                            }

                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: Text("Set the filter",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF6200EE),
                                      )),
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text(
                                        "Distance",
                                        style: headerStyle,
                                      ),
                                      Container(
                                        width: 300.0,
                                        height: 50.0,
                                        child: FlutterSlider(
                                          values: [
                                            _defaultSearchDistance * 1.0
                                          ],
                                          rangeSlider: false,
                                          max: 10000,
                                          min: 100,
                                          onDragging: (handlerIndex, lowerValue,
                                              upperValue) {
                                            distance = _defaultSearchDistance =
                                                lowerValue.floor();
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      Text("distance <= $distance m."),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Divider(
                                        color: Colors.blueGrey,
                                        height: 10.0,
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text(
                                        "Reported by",
                                        style: headerStyle,
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Radio(
                                              value: 0,
                                              groupValue: groupValueReportedBy,
                                              onChanged: (index) {
                                                _handleReportedByRadioButton(
                                                    index);
                                                setState(() {});
                                              },
                                            ),
                                            Text("All"),
                                            Radio(
                                              value: 1,
                                              groupValue: groupValueReportedBy,
                                              onChanged: (index) {
                                                _handleReportedByRadioButton(
                                                    index);
                                                setState(() {});
                                              },
                                            ),
                                            Text("Only me"),
                                            Radio(
                                              value: 2,
                                              groupValue: groupValueReportedBy,
                                              onChanged: (index) {
                                                _handleReportedByRadioButton(
                                                    index);
                                                setState(() {});
                                              },
                                            ),
                                            Text("Only Others"),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.blueGrey,
                                        height: 10.0,
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        "Sort by (no. of report)",
                                        style: headerStyle,
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Radio(
                                              value: 0,
                                              groupValue: groupValueSortBy,
                                              onChanged: (index) {
                                                _handleSortByRadioButton(index);
                                                setState(() {});
                                              },
                                            ),
                                            Text("Highest to Lowest"),
                                            Radio(
                                              value: 1,
                                              groupValue: groupValueSortBy,
                                              onChanged: (index) {
                                                _handleSortByRadioButton(index);
                                                setState(() {});
                                              },
                                            ),
                                            Text("Lowest to Highest"),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Divider(
                                        color: Colors.blueGrey,
                                        height: 10.0,
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    RaisedButton(
                                      child: Text("Submit"),
                                      onPressed: () {
                                        _intelligentFetchReportedCasesData();
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      icon: Icon(
                        FontAwesomeIcons.filter,
                        color: Colors.white,
                        size: 15.0,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

//GestureDetector(
//              child: Container(
//                color: Color(0xFF6200EE),
//                child: Icon(
//                  Icons.donut_large,
//                  color: Colors.white,
//                ),
//              ),
//            )
