import 'package:flutter/widgets.dart';

extension PaddingExtension on Widget {

  Widget padded({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) => Padding(
    padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom,),
    child: this,
  );

  Widget paddedAll(double value,) => Padding(
    padding: EdgeInsets.all(value,),
    child: this,
  );

  Widget symmetricPadding({double vertical = 0.0, double horizontal = 0.0,}) => Padding(
    padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal,),
    child: this,
  );
}