import 'package:flutter/material.dart';

class FullScreenPage extends StatelessWidget {

  final Color color;
  final Gradient gradient;
  final Widget child;

  const FullScreenPage({
    Key key,
    this.color,
    this.gradient,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Material(
      color: color ?? Colors.white,
      child: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: gradient,
        ),
        child: this,
      ),
    );
  }
}