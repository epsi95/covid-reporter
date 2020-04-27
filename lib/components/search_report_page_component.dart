import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'user_point.dart';
import 'package:lottie/lottie.dart';

class SearchReportMap extends StatefulWidget {
  final List<dynamic> data;
  final LocationData location;
  final int searchDistance;

  SearchReportMap({this.data, this.location, this.searchDistance});

  @override
  _SearchReportMapState createState() => _SearchReportMapState();
}

class _SearchReportMapState extends State<SearchReportMap> {
  List<CircleMarker> _circleMarkers = [];

  List<Marker> _markers = [];

  void _populateCircleLayerAndMarkers() {
    _markers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(widget.location.latitude, widget.location.longitude),
        builder: (ctx) => UserPoint()));

    for (dynamic each in widget.data) {
      print(each);
      print(LatLng(double.parse(each["reported_lat"]),
          double.parse(each["reported_lon"])));
      _markers.add(Marker(
        width: 80.0,
        height: 160.0,
        point: LatLng(double.parse(each["reported_lat"]),
            double.parse(each["reported_lon"])),
        builder: (ctx) => DetectedCaseMarker(),
      ));
    }

    _circleMarkers.add(CircleMarker(
        point: LatLng(widget.location.latitude, widget.location.longitude),
        radius: widget.searchDistance * 1.0,
        useRadiusInMeter: true,
        color: Colors.red.withOpacity(0.2),
        borderColor: Colors.red,
        borderStrokeWidth: 2.0));
  }

  @override
  Widget build(BuildContext context) {
    _markers.clear();
    _circleMarkers.clear();
    _populateCircleLayerAndMarkers();
    print("_markers" + _markers.length.toString());
    print("_circles" + _circleMarkers.length.toString());
    print(_markers);
    return Container(
      child: FlutterMap(
        options: MapOptions(
          center: LatLng(widget.location.latitude, widget.location.longitude),
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
