import 'package:covid_reporter/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'pages/status_page.dart';
import 'pages/dashboard.dart';
import 'pages/dashboardV2.dart';
import 'pages/splash_screen.dart';
import 'pages/new_user_registration.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
