import 'package:flutter/material.dart';

class UserPoint extends StatefulWidget {
  final double radius;

  UserPoint({this.radius = 300.0});

  @override
  _UserPointState createState() => _UserPointState();
}

class _UserPointState extends State<UserPoint>
    with SingleTickerProviderStateMixin {
  AnimationController _animController;
  Animation animation;
  double _radius;

  @override
  void initState() {
    _radius = widget.radius;
    // _fetchData() is your function to fetch data
    _animController = AnimationController(
        vsync: this, // the SingleTickerProviderStateMixin
        duration: Duration(seconds: 1),
        reverseDuration: Duration(milliseconds: 10));
    animation = CurvedAnimation(
        curve: Curves.easeInOutCubic,
        parent: _animController,
        reverseCurve: Curves.linear);
    _animController.forward();
    _animController.addListener(() {
      setState(() {});
    });
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _animController.forward();
      } else if (status == AnimationStatus.completed) {
        _animController.reverse(from: 1.0);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          width: _radius * 2 * animation.value,
          height: _radius * 2 * animation.value,
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(1 - animation.value),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 20.0,
          height: 20.0,
          decoration: BoxDecoration(
            color: Colors.indigo,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
