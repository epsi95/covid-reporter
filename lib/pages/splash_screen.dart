import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dashboardV2.dart';
import 'package:covid_reporter/utils/storage_read_write.dart';
import 'new_user_registration.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:covid_reporter/constants/constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _encryptedUserID;
  bool _isError = false;
  String _errorText = "error";
  String _firstText = "";
  String _secondText = "";
  bool _first = true;
  bool toggleData;
  Timer timer;
  final StorageReadWrite readWrite = StorageReadWrite();
  final List<String> whatToDo = [
    "WASH YOUR HANDS",
    "AVOID CLOSE CONTACTS",
    "STAY AT HOME",
    "NO PUBLIC GATHERING",
    "DO NOT PANIC",
    "SICK? CAll HELPLINE",
    "KEEP WARM",
    "DRINK PLENTY LIQUIDS",
    "REST AND SLEEP",
    "COVER YOUR COUGH",
  ];

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12 && hour >= 4) {
      return 'GOOD MORNING';
    }
    if (hour < 17 && hour >= 12) {
      return 'GOOD AFTERNOON';
    }
    if (hour < 20 && hour >= 17) {
      return 'GOOD EVENING';
    }
    return "IT\'S DARK 🌃";
  }

  bool toggleFirst() {
    setState(() {
      _first = !_first;
    });
    return _first;
  }

  void startAnimation() {
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        toggleData = toggleFirst();
        if (toggleData == false) {
          _firstText = whatToDo[Random().nextInt(10)];
        } else {
          _secondText = whatToDo[Random().nextInt(10)];
        }
      });
    });
  }

  void fetchUserIDFromStorageAndAuthenticateIt() async {
    _encryptedUserID = await readWrite.readFile();
    print(_encryptedUserID);
    if (_encryptedUserID == "error") {
      timer.cancel();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => NewUserRegistration()));
    } else {
      // now we need to validate user
      try {
        var response = await http.post(kAuthUserUrl,
            body: convert.json.encode({
              "auth_key": kAuthKey,
              "encrypted_id": _encryptedUserID,
            }),
            headers: {
              'Content-Type': 'application/json'
            }).timeout(Duration(seconds: 20));
        print(response.body);
        var data = convert.jsonDecode(response.body)["data"];
        if (data["response"] == "success") {
          timer.cancel();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => DashboardV2(
                        userID: _encryptedUserID,
                      )));
        } else {
          timer.cancel();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => NewUserRegistration()));
//          _errorText = "😔";
//          _isError = true;
//          setState(() {});
        }
      } catch (e) {
        print(e);
        _errorText = "😔";
        _isError = true;
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    _firstText = "Hi,";
    _secondText = greeting();
    startAnimation();
    Future.delayed(const Duration(seconds: 4), () {
      fetchUserIDFromStorageAndAuthenticateIt();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6200EE),
      body: Center(
        child: _isError
            ? Center(
                child: Text(
                  _errorText,
                  style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : AnimatedCrossFade(
                duration: const Duration(milliseconds: 600),
                firstCurve: Curves.easeIn,
                secondCurve: Curves.easeOut,
                firstChild: Text(
                  _firstText,
                  style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                secondChild: Text(
                  _secondText,
                  style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                crossFadeState: _first
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
              ),
      ),
    );
  }
}
