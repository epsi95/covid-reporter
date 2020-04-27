import 'package:flutter/material.dart';

const kBottomTabBarHeight = 46.0;
const kCameraIconScale = 1.4;
const kFABIconScale = 0.4;
const kHeaderPadding = EdgeInsets.only(top: 8.0);
const kCameraButtonWidth = 15.0;
const kBottomTabTextStyle = TextStyle(
  fontSize: 15.0,
  fontWeight: FontWeight.w700,
);

const kAllIndiaDataUrl = "https://api.covid19india.org/data.json";
const kStateDataUrl = "https://api.covid19india.org/state_district_wise.json";
const kGetUserIDUrl = "https://cat95.pythonanywhere.com/getUserID";
const kAuthUserUrl = "https://cat95.pythonanywhere.com/validateUserID";
const kReportCaseUrl = "https://cat95.pythonanywhere.com/reportCase";
const kGetReportedCasesUrl =
    "https://cat95.pythonanywhere.com/getReportedCases";
const kDeleteReportedCase =
    "https://cat95.pythonanywhere.com/deleteReportedCase";
const kCiteReportedCase = "https://cat95.pythonanywhere.com/citeReportedCase";

const kAuthKey = "sy%6sO128?o*shH@";

const kReportAgreement =
    "I understand my responsibility. I assure that I am not reporting any FALSE information.";
