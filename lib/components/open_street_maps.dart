import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:covid_reporter/components/user_point.dart';
import 'package:lottie/lottie.dart';

class OpenStreetMaps extends StatefulWidget {
  final _OpenStreetMapsState _openStreetMapsState = _OpenStreetMapsState();
  void gotoUserLocation() {
    _openStreetMapsState._gotoUserLocation();
  }

  void deleteReportingPoint() {
    _openStreetMapsState._deleteReportingPoint();
  }

  LatLng getReportedLocationMarker() {
    return _openStreetMapsState._getReportedLocationMarker();
  }

  LatLng getUserLocation() {
    return _openStreetMapsState._getUserLocation();
  }

  double getMarkerAndUserDistance() {
    return _openStreetMapsState._getMarkerAndUserDistance();
  }

  String toggleAutoUpdate() {
    return _openStreetMapsState._toggleAutoUpdate();
  }

  @override
  _OpenStreetMapsState createState() {
    return _openStreetMapsState;
  }
}

class _OpenStreetMapsState extends State<OpenStreetMaps> {
  //parameters to control map
//  AnimationController controller;
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  MapController _mapController = MapController();
  double baseTimeForMapAnimation = 0.0;
  double deltaTimeForMapAnimation = 1 / 60;
  LatLng _lastTappedLocation;
  bool _autoUpdateUserLocation = false;
  String _animatedContainerText = "auto refresh off";
  Color _animatedContainerColor = Colors.redAccent;
  double _userAndVictimDistance = 0.0;
  TextStyle bannerTextStyle =
      TextStyle(color: Colors.white, fontWeight: FontWeight.w600);

  List<CustomMarker> _markers = [];
  List<CircleMarker> _circleMarkers = [];

  @override
  void initState() {
//    controller =
//        AnimationController(vsync: this, duration: Duration(seconds: 1));
//    controller.addStatusListener((status) {
//      if (status == AnimationStatus.completed) {
//        controller.reverse();
//      } else if (status == AnimationStatus.dismissed) {
//        controller.forward();
//      }
//    });
//    controller.forward();
//    controller.addListener(() {
//      setState(() {});
//    });
    initiateLocation();
    super.initState();
  }

  @override
  void dispose() {
//    controller.dispose();
    super.dispose();
  }

  void _deleteReportingPoint() {
    _markers.removeLast();
    _circleMarkers.clear();
    _lastTappedLocation = null;
    setState(() {});
  }

  String _toggleAutoUpdate() {
    _autoUpdateUserLocation = !_autoUpdateUserLocation;
    return _autoUpdateUserLocation ? "on" : "off";
  }

  void _gotoUserLocation() {
    _simpleGoToLocation(
        LatLng(_locationData.latitude, _locationData.longitude), 13.0);
  }

  LatLng _getReportedLocationMarker() {
    return _lastTappedLocation;
  }

  LatLng _getUserLocation() {
    return LatLng(_locationData.latitude, _locationData.longitude);
  }

  void initiateLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    print("updating location for the first time");
    print(_locationData);
    _updateLocation(_locationData);
    location.onLocationChanged.listen((LocationData currentLocation) {
      // Use current location
      if (mounted) {
        _updateLocationData(currentLocation);
      }
    });
  }

  void _updateUserMarkerList() {
    if (_markers.length == 0) {
      _markers.add(CustomMarker(
        id: "user_location",
        width: 80.0,
        height: 80.0,
        point: LatLng(_locationData.latitude, _locationData.longitude),
        builder: (ctx) => Container(
          child: UserPoint(),
        ),
      ));
    } else if (_markers.first.id == "user_location") {
      _markers.removeAt(0);
      _markers.insert(
          0,
          CustomMarker(
            id: "user_location",
            width: 80.0,
            height: 80.0,
            point: LatLng(_locationData.latitude, _locationData.longitude),
            builder: (ctx) => Container(
              child: UserPoint(),
            ),
          ));
    } else {
      _markers.insert(
          0,
          CustomMarker(
            id: "user_location",
            width: 80.0,
            height: 80.0,
            point: LatLng(_locationData.latitude, _locationData.longitude),
            builder: (ctx) => Container(
              child: UserPoint(),
            ),
          ));
    }
  }

  void _updateLocationData(LocationData locationData) {
    _locationData = locationData;
    if (_autoUpdateUserLocation) {
      _updateCircleMarker();
      LatLng topLeft = _mapController.bounds.northWest;
      LatLng topRight = _mapController.bounds.northEast;
      LatLng bottomRight = _mapController.bounds.southWest;
      bool isWithinHorizontal =
          ((_locationData.longitude > topRight.longitude) &&
                  (_locationData.longitude < topLeft.longitude)) ||
              ((_locationData.longitude < topRight.longitude) &&
                  (_locationData.longitude > topLeft.longitude));
      bool isWithinVertical = ((_locationData.latitude > topRight.latitude) &&
              (_locationData.latitude < bottomRight.latitude)) ||
          ((_locationData.latitude < topRight.latitude) &&
              (_locationData.latitude > bottomRight.latitude));
      if (isWithinHorizontal && isWithinVertical) {
        print("within screen");
        _updateUserMarkerList();
        _userAndVictimDistance = _getMarkerAndUserDistance();
      } else {
        _updateUserMarkerList();
        _userAndVictimDistance = _getMarkerAndUserDistance();
        _simpleGoToLocation(
            LatLng(_locationData.latitude, _locationData.longitude), -1);
      }
    } else {
      _updateUserMarkerList();
      _userAndVictimDistance = _getMarkerAndUserDistance();
      _updateCircleMarker();
      setState(() {});
    }
  }

  void _updateLocation(LocationData locationData) {
    _locationData = locationData;
    _updateUserMarkerList();
//    animateToNewLocation(
//        LatLng(_locationData.latitude, _locationData.longitude), 13.0);
    _simpleGoToLocation(
        LatLng(_locationData.latitude, _locationData.longitude), 13.0);
  }

  void _simpleGoToLocation(LatLng newLocation, double newZoom) {
    _mapController.onReady.then((result) {
      print("moving to: ");
      print(newLocation);
      LatLng finalCenter = newLocation;
      double finalZoomLevel = newZoom == -1 ? _mapController.zoom : newZoom;
      _mapController.move(finalCenter, finalZoomLevel);
    });
  }

  double _getMarkerAndUserDistance() {
    if (_markers.length > 1) {
      Distance distance = Distance();
      return distance(_circleMarkers.last.point, _markers.last.point);
    } else {
      return -1;
    }
  }

  void _updateCircleMarker() {
    _circleMarkers.clear();
    if (_lastTappedLocation != null) {
      Distance distance = Distance();
      _circleMarkers.add(CircleMarker(
          point: LatLng(_locationData.latitude, _locationData.longitude),
          radius: distance(_lastTappedLocation,
              LatLng(_locationData.latitude, _locationData.longitude)),
          useRadiusInMeter: true,
          color: Colors.red.withOpacity(0.2),
          borderColor: Colors.red,
          borderStrokeWidth: 2.0));
    }
  }

//  void animateToNewLocation(LatLng newLocation, double newZoom) {
//    _mapController.onReady.then((result) {
//      print("moving to: ");
//      print(newLocation);
//      LatLng topLeft = _mapController.bounds.northWest;
//      LatLng topRight = _mapController.bounds.northEast;
//      LatLng bottomRight = _mapController.bounds.southWest;
//
//      LatLng currentCenter = LatLng(
//          (topLeft.latitude + bottomRight.latitude) / 2,
//          (topLeft.longitude + topRight.longitude) / 2);
//      LatLng finalCenter = newLocation;
//      double currentZoomLevel = _mapController.zoom;
//      double finalZoomLevel = newZoom;
//      baseTimeForMapAnimation = 0.0;
//      controller.addListener(() {
//        if (baseTimeForMapAnimation <= 1) {
//          if (currentZoomLevel <= finalZoomLevel) {
//            double intermediateZoomLevel = (finalZoomLevel - currentZoomLevel) *
//                    (baseTimeForMapAnimation *
//                        baseTimeForMapAnimation *
//                        (3.0 - 2.0 * baseTimeForMapAnimation)) +
//                currentZoomLevel;
//            double intermediateLat =
//                (finalCenter.latitude - currentCenter.latitude) *
//                        (baseTimeForMapAnimation *
//                            baseTimeForMapAnimation *
//                            (3.0 - 2.0 * baseTimeForMapAnimation)) +
//                    currentCenter.latitude;
//            double intermediateLon =
//                (finalCenter.longitude - currentCenter.longitude) *
//                        (baseTimeForMapAnimation *
//                            baseTimeForMapAnimation *
//                            (3.0 - 2.0 * baseTimeForMapAnimation)) +
//                    currentCenter.longitude;
//            print(intermediateZoomLevel);
//            _mapController.move(LatLng(intermediateLat, intermediateLon),
//                intermediateZoomLevel);
//            baseTimeForMapAnimation += deltaTimeForMapAnimation;
//          }
//        } else if (baseTimeForMapAnimation > 1) {
//          return;
//        }
//      });
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            onTap: (LatLng tappedLocation) {
              _lastTappedLocation = tappedLocation;
              if (_markers.length > 0) {
                if (_markers.last.id == "detected_case") {
                  _markers.removeLast();
                }
              }
              _markers.add(
                CustomMarker(
                  id: "detected_case",
                  width: 80.0,
                  height: 160.0,
                  point: tappedLocation,
                  builder: (ctx) => DetectedCaseMarker(),
                ),
              );
              _updateCircleMarker();
              setState(() {});
              _userAndVictimDistance = _getMarkerAndUserDistance();
//          _callBackFunction(tappedLocation, _getMarkerAndUserDistance());
            },
            center: LatLng(28.7041, 77.1025),
            zoom: 13.0,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            CircleLayerOptions(
              circles: _circleMarkers,
            ),
            MarkerLayerOptions(
              markers: _markers,
            ),
          ],
        ),
        Positioned(
          top: 20.0,
          left: 20.0,
          child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10.0)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Reporting Area Radius",
                    style: bannerTextStyle,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    (_userAndVictimDistance == -1
                                ? 0
                                : _userAndVictimDistance.ceil())
                            .toString() +
                        " m.",
                    style: bannerTextStyle,
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20.0,
          right: 20.0,
          child: Container(
            width: 100.0,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    print(_animatedContainerText);
                    String status = _toggleAutoUpdate();
                    _animatedContainerText =
                        status == "on" ? "auto refresh on" : "auto refresh off";
                    _animatedContainerColor =
                        status == "on" ? Colors.lightGreen : Colors.redAccent;
                    setState(() {});
                  },
                  child: AnimatedContainer(
                    padding: EdgeInsets.all(10.0),
                    duration: Duration(seconds: 1),
                    decoration: BoxDecoration(
                      color: _animatedContainerColor,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Center(
                        child: Text(
                      _animatedContainerText,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    )),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  color: Color(0xFF6200EE),
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "my location",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    _gotoUserLocation();
                  },
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DetectedCaseMarker extends StatelessWidget {
  const DetectedCaseMarker({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5.0),
            height: 100.0,
            child: Lottie.asset('assets/695-bouncy-mapmaker.json'),
          ),
          SizedBox(
            height: 60.0,
          )
        ],
      ),
    );
  }
}

class CustomMarker extends Marker {
  final String id;
  final double width;
  final double height;
  final LatLng point;
  final Widget Function(BuildContext) builder;
  CustomMarker({this.id, this.width, this.height, this.point, this.builder})
      : super(width: width, height: height, point: point, builder: builder);
}
