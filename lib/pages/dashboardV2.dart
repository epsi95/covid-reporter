import 'package:flutter/material.dart';
import 'status_page.dart';
import 'report_corona.dart';
import 'search_page.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardV2 extends StatefulWidget {
  final String userID;
  DashboardV2({@required this.userID});
  @override
  _DashboardV2State createState() => _DashboardV2State();
}

class _DashboardV2State extends State<DashboardV2> {
  int _currentIndex = 0;
  String _userID;
//  final List<Widget> _children = [StatusPage(), ReportCorona(), Text("search")];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      print(_currentIndex);
    });
  }

  void _sendMail() async {
    // Android and iOS
    const uri =
        'mailto:probhakar.95@gmail.com?subject=COVID-REPORTER BUG REPORT V 1.0.0&body=Hi,';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
//      throw 'Could not launch $uri';
      showSnackBar("Could not launch Gmail");
    }
  }

  void showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text(message),
      ),
    );
  }

  @override
  void initState() {
    _userID = widget.userID;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color(0xFF6200EE),
          title: Text(
            'COVID REPORTER',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 21.0,
            ),
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'report bug',
              onPressed: () {
                showSnackBar("Send bug report");
                _sendMail();
              },
              icon: Icon(
                Icons.bug_report,
                color: Colors.white,
              ),
            )
          ],
        ),
        body:
//        _currentIndex == 0
//            ? StatusPage()
//            :
            _currentIndex == 0
                ? ReportCorona(
                    userID: _userID,
                    callBackFunction: (String message) {
                      showSnackBar(message);
                    },
                  )
                : SearchPage(
                    userID: _userID,
                    callbackFunction: (String message) {
                      showSnackBar(message);
                    },
                  ), //_children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xFF6200EE),
          onTap: onTabTapped,
          currentIndex: 0, // this will be set when a new tab is tapped
          items: [
//            BottomNavigationBarItem(
//              icon: Icon(
//                Icons.pie_chart,
//                color: _currentIndex == 0 ? Colors.white : Color(0xFFD6BDFB),
//              ),
//              title: Text(
//                'INDIA',
//                style: TextStyle(
//                    color:
//                        _currentIndex == 0 ? Colors.white : Color(0xFFD6BDFB)),
//              ),
//            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.report_problem,
                color: _currentIndex == 1 ? Colors.white : Color(0xFFD6BDFB),
              ),
              title: Text(
                'REPORT',
                style: TextStyle(
                    color:
                        _currentIndex == 1 ? Colors.white : Color(0xFFD6BDFB)),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                color: _currentIndex == 2 ? Colors.white : Color(0xFFD6BDFB),
              ),
              title: Text(
                'SEARCH',
                style: TextStyle(
                    color:
                        _currentIndex == 2 ? Colors.white : Color(0xFFD6BDFB)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
