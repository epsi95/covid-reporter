import 'package:flutter/material.dart';

class WhatIsThis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6200EE),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(
          Icons.arrow_back,
          color: Color(0xFF6200EE),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Text(
            """we store your encrypted identity in your local storage to validate you. If you're using the app for the first time, or you're reinstalling it or you ran some cleaner utility that will delete the encrypted file. \n\nDon't worry, just generate a new one.""",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );
  }
}
