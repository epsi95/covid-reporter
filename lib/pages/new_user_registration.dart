import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:covid_reporter/constants/constants.dart';
import 'dart:convert' as convert;
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:covid_reporter/utils/get_user_location.dart';
import 'package:location/location.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:covid_reporter/utils/storage_read_write.dart';
import 'dashboardV2.dart';
import 'what_is_this.dart';

class NewUserRegistration extends StatefulWidget {
  @override
  _NewUserRegistrationState createState() => _NewUserRegistrationState();
}

class _NewUserRegistrationState extends State<NewUserRegistration> {
  double _ageLower = 20;
  double _ageUpper = 40;
  double _lat = 28.4999233;
  double _lon = 77.0682333;
  int _gender = 0; //0-female 1-male 2-other
  int _groupValue = 0;
  String _locationMessage = "get location";
  Color _locationColor = Colors.redAccent;
  bool _isButtonEnable = false;
  bool _isModalProgressHudActive = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _toggleModalProgressHud() {
    setState(() {
      _isModalProgressHudActive = !_isModalProgressHudActive;
    });
  }

  void _handleRadioValueChange(int index) {
    _gender = index;
    _groupValue = index;
  }

  void _getLocation() async {
    GetUserLocation getUserLocation = GetUserLocation();
    LocationData locationData;
    try {
      Location location = await getUserLocation.getLocation();
      locationData = await location.getLocation();
    } catch (e) {
      print(e);
    }

    if (locationData == null) {
      _locationMessage = "location error";
      _locationColor = Colors.red;
      setState(() {});
    } else {
      _lat = locationData.latitude;
      _lon = locationData.longitude;
      _locationMessage = "success";
      _locationColor = Colors.lightGreen;
      _isButtonEnable = true;
//      print(_ageUpper);
//      print(_ageLower);
//      print(_gender);
//      print(_lat);
//      print(_lon);
      setState(() {});
    }
  }

  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Color(0xFF6200EE),
          body: ModalProgressHUD(
            inAsyncCall: _isModalProgressHudActive,
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Hi, seems new user",
                        style: TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          print("tapped");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      WhatIsThis()));
                        },
                        child: Text(
                          "what's this?",
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.white70,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Container(
                    height: 120.0,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "my age is bewtween ${_ageLower.floor()} - ${_ageUpper.floor()}",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 20.0),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        FlutterSlider(
                          trackBar: FlutterSliderTrackBar(
                            inactiveTrackBar: BoxDecoration(
                              color: Color(0xFF6200EE),
                            ),
                            activeTrackBar: BoxDecoration(color: Colors.white),
                          ),
                          values: [20, 40],
                          rangeSlider: true,
                          max: 100,
                          min: 1,
                          onDragging: (handlerIndex, lowerValue, upperValue) {
                            _ageLower = lowerValue;
                            _ageUpper = upperValue;
                            setState(() {});
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    height: 120.0,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "I am ${_gender == 0 ? "female" : _gender == 1 ? "male" : "other"}",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 20.0),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Radio(
                              value: 0,
                              activeColor: Colors.white,
                              groupValue: _groupValue,
                              onChanged: (index) {
                                _handleRadioValueChange(index);
                                setState(() {});
                              },
                            ),
                            Icon(
                              FontAwesomeIcons.female,
                              color: Colors.white,
                            ),
                            Radio(
                              value: 1,
                              activeColor: Colors.white,
                              groupValue: _groupValue,
                              onChanged: (index) {
                                _handleRadioValueChange(index);
                                setState(() {});
                              },
                            ),
                            Icon(FontAwesomeIcons.male, color: Colors.white),
                            Radio(
                              value: 2,
                              activeColor: Colors.white,
                              groupValue: _groupValue,
                              onChanged: (index) {
                                _handleRadioValueChange(index);
                                setState(() {});
                              },
                            ),
                            Icon(FontAwesomeIcons.genderless,
                                color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    height: 120.0,
                    width: double.infinity,
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: FractionallySizedBox(
                      heightFactor: 0.5,
                      widthFactor: 0.7,
                      child: GestureDetector(
                        onTap: () {
                          _locationColor = Colors.blueGrey;
                          _locationMessage = "fetching..";
                          _getLocation();
                          setState(() {});
                        },
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            color: _locationColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          duration: Duration(seconds: 1),
                          child: Center(
                            child: Text(
                              _locationMessage,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Center(
                    child: RaisedButton(
                      onPressed: !_isButtonEnable
                          ? null
                          : () async {
                              _toggleModalProgressHud();
                              setState(() {});
                              try {
                                var response = await http.post(kGetUserIDUrl,
                                    body: convert.json.encode({
                                      "auth_key": kAuthKey,
                                      "age_lower": _ageLower.floor().toString(),
                                      "age_upper": _ageUpper.floor().toString(),
                                      "lat": _lat.toString(),
                                      "lon": _lon.toString(),
                                      "gender": _gender == 0
                                          ? "F"
                                          : _gender == 1 ? "M" : "O"
                                    }),
                                    headers: {
                                      'Content-Type': 'application/json'
                                    }).timeout(Duration(seconds: 10));
                                print(response.body);
                                var data =
                                    convert.jsonDecode(response.body)["data"];
                                if (data["response"] == "success") {
                                  _showSnackBar(
                                      "success getting user id, now storing it");
                                  StorageReadWrite storageReadWrite =
                                      StorageReadWrite();
                                  try {
                                    await storageReadWrite
                                        .writeFile(data["id"])
                                        .then((_) {
                                      _showSnackBar(
                                          "successfully stored id to local storage");
                                      _toggleModalProgressHud();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  DashboardV2(
                                                    userID: data["id"],
                                                  )));
                                    });
                                  } catch (e) {
                                    print(e);
                                    _showSnackBar("unable to store user id");
                                    _toggleModalProgressHud();
                                  }
                                } else {
                                  _toggleModalProgressHud();
                                  _showSnackBar("unable to get user id");
                                }
                              } catch (e) {
                                _toggleModalProgressHud();
                                print(e);
                                _showSnackBar("can't connect to internet.");
                              }
                            },
                      child: Text(
                        "Let's beat C19 together",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
