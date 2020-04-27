import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:covid_reporter/components/open_street_maps.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:covid_reporter/constants/constants.dart';

class ReportCorona extends StatefulWidget {
  final Function(String) callBackFunction;
  final String userID;
  ReportCorona({this.callBackFunction, @required this.userID});
  @override
  _ReportCoronaState createState() => _ReportCoronaState();
}

class _ReportCoronaState extends State<ReportCorona> {
  OpenStreetMaps openStreetMaps = OpenStreetMaps();
  Function _callBackFunction;
  double _loweValueOfAge = 30;
  double _upperValueOfAge = 40;
  int _sexSelected = 0; //0-female 1-male 2-other
  DateTime _dateOfCoronaKnowledge = DateTime.now();
  String _detectedCaseDescription;
  bool _validate = false;
  final _text = TextEditingController();
  bool _isTermsAndConditionSelected = true;
  bool _isButtonDisabled = false;
  bool _isModalProgressHudActive = false;
  String _userID;

  void _toggleModalProgressHud() {
    setState(() {
      print("toggle modal progress called");
      print(_isModalProgressHudActive);
      _isModalProgressHudActive = !_isModalProgressHudActive;
    });
  }

  void _reportCoronaCase() async {
    try {
      var payLoad = {
        "auth_key": kAuthKey,
        "case_lat":
            openStreetMaps.getReportedLocationMarker().latitude.toString(),
        "case_lon":
            openStreetMaps.getReportedLocationMarker().longitude.toString(),
        "case_age_lower": _loweValueOfAge.floor().toString(),
        "case_age_upper": _upperValueOfAge.floor().toString(),
        "case_gender": _sexSelected == 0 ? "F" : _sexSelected == 1 ? "M" : "O",
        "date_of_information": _dateOfCoronaKnowledge.toString().split(" ")[0],
        "date_of_report": DateTime.now().toString().split(" ")[0],
        "note": _detectedCaseDescription,
        "reported_by": _userID
      };
      print(_dateOfCoronaKnowledge);
//      print(DateTime.now().toUtc());
//      print(DateTime.now().toIso8601String());
//      print(payLoad);
      var response = await http.post(kReportCaseUrl,
          body: convert.json.encode(payLoad),
          headers: {
            'Content-Type': 'application/json'
          }).timeout(Duration(seconds: 10));
      print(response.body);
      var data = convert.jsonDecode(response.body)["data"];
      if (data["response"] == "success") {
        _callBackFunction("case report successful");
        openStreetMaps.deleteReportingPoint();
        _loweValueOfAge = 30;
        _upperValueOfAge = 40;
        _sexSelected = 0; //0-female 1-male 2-other
        _dateOfCoronaKnowledge = DateTime.now();
        _detectedCaseDescription = null;
        _text.clear();
        _toggleModalProgressHud();
      } else {
        _callBackFunction("failed to report case");
        _toggleModalProgressHud();
      }
    } catch (e) {
      print(e);
      _callBackFunction("unable to connect to internet");
      _toggleModalProgressHud();
    }
  }

  @override
  void initState() {
    _userID = widget.userID;
    _callBackFunction = widget.callBackFunction;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isModalProgressHudActive,
      color: Colors.black,
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6200EE)),
      ),
      child: Stack(
        children: <Widget>[
          openStreetMaps,
          Positioned(
              top: 20.0,
              right: 20.0,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                color: Color(0xFF6200EE),
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "report corona case",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  LatLng reportingLocation =
                      openStreetMaps.getReportedLocationMarker();
                  if (reportingLocation == null) {
                    _callBackFunction(
                        "Tap on the map to point the location of reported COVID-19 case.nn");
                  } else {
                    if (openStreetMaps.getMarkerAndUserDistance() > 10000) {
                      _callBackFunction(
                          "You can't report a case which is > 10km from your location");
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          double lowerAge = _loweValueOfAge;
                          double upperAge = _upperValueOfAge;
                          int groupValue = 0;
                          DateTime selectedDate = DateTime.now();
                          String dateString = "select date";
                          bool buttonDisabled = _isButtonDisabled;
                          bool checkBoxChecked = _isTermsAndConditionSelected;
                          TextStyle headerStyle = TextStyle(
                            fontWeight: FontWeight.w700,
                          );
                          void _handleRadioValueChange(int index) {
                            _sexSelected = index;
                            print("sex selected " + _sexSelected.toString());
                            groupValue = index;
                          }

                          Future<Null> _selectDate(BuildContext context) async {
                            final DateTime picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2019, 1),
                                lastDate: DateTime.now());
                            if (picked != null) {
                              selectedDate = picked;
                              _dateOfCoronaKnowledge = picked;
                              dateString = picked.day.toString() +
                                  " / " +
                                  picked.month.toString() +
                                  " / " +
                                  picked.year.toString();
                            }
                          }

                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                title: Text("Details of the patient",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF6200EE),
                                    )),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text(
                                        "Age",
                                        style: headerStyle,
                                      ),
                                      Container(
                                        width: 300.0,
                                        height: 50.0,
                                        child: FlutterSlider(
                                          values: [30, 40],
                                          rangeSlider: true,
                                          max: 100,
                                          min: 1,
                                          onDragging: (handlerIndex, lowerValue,
                                              upperValue) {
                                            _loweValueOfAge = lowerValue;
                                            _upperValueOfAge = upperValue;
                                            setState(() {
                                              lowerAge = lowerValue;
                                              upperAge = upperValue;
                                            });
                                          },
                                        ),
                                      ),
                                      Text("age range: " +
                                          lowerAge.floor().toString() +
                                          " - " +
                                          upperAge.floor().toString()),
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
                                        "Gender",
                                        style: headerStyle,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Radio(
                                            value: 0,
                                            groupValue: groupValue,
                                            onChanged: (index) {
                                              _handleRadioValueChange(index);
                                              setState(() {});
                                            },
                                          ),
                                          Icon(FontAwesomeIcons.female),
                                          Radio(
                                            value: 1,
                                            groupValue: groupValue,
                                            onChanged: (index) {
                                              _handleRadioValueChange(index);
                                              setState(() {});
                                            },
                                          ),
                                          Icon(FontAwesomeIcons.male),
                                          Radio(
                                            value: 2,
                                            groupValue: groupValue,
                                            onChanged: (index) {
                                              _handleRadioValueChange(index);
                                              setState(() {});
                                            },
                                          ),
                                          Icon(FontAwesomeIcons.genderless),
                                        ],
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
                                      Text(
                                        "Date you got the informtion",
                                        style: headerStyle,
                                      ),
                                      RaisedButton(
                                        child: Text(dateString),
                                        onPressed: () async {
                                          await _selectDate(context);
                                          print("dateString" + dateString);
                                          print(_dateOfCoronaKnowledge);
                                          setState(() {});
                                        },
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
                                      Text(
                                        "Tell something about the patient",
                                        style: headerStyle,
                                      ),
                                      TextField(
                                        controller: _text,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 5,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'write...',
                                          errorText: _validate
                                              ? 'Patient Details Can\'t Be Empty'
                                              : null,
                                        ),
                                        onChanged: (text) {
                                          _text.text.isEmpty
                                              ? _validate = true
                                              : _validate = false;
                                          _detectedCaseDescription = text;
                                          print(_detectedCaseDescription);
                                          setState(() {});
                                        },
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
                                      Row(
                                        children: <Widget>[
                                          Checkbox(
                                            value: checkBoxChecked,
                                            onChanged: (bool value) {
                                              setState(() {
                                                checkBoxChecked =
                                                    _isTermsAndConditionSelected =
                                                        value;
                                                _isButtonDisabled =
                                                    buttonDisabled =
                                                        value == false
                                                            ? true
                                                            : false;
                                                setState(() {});
                                              });
                                            },
                                          ),
                                          Container(
                                            width: 200.0,
                                            child: Text(kReportAgreement),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  RaisedButton(
                                    child: Text("Submit"),
                                    onPressed: buttonDisabled
                                        ? null
                                        : () {
                                            if (_text.text.isEmpty) {
                                              setState(() {
                                                _validate = true;
                                                return;
                                              });
                                            } else {
                                              _validate = false;
                                              // call some network operation function
                                              _toggleModalProgressHud();
                                              _reportCoronaCase();
                                              Navigator.pop(context);
                                            }
                                          },
                                  )
                                ],
                              );
                            },
                          );
                        },
                      );
                    }
                  }
                },
              ))
        ],
      ),
    );
  }
}
