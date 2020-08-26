import 'package:flutter/widgets.dart';

extension SizingExtensions on Widget {

  Widget get maxWidth => SizedBox(
    width: double.infinity,
    child: this,
  );

  Widget get maxHeight => SizedBox(
    height: double.infinity,
    child: this,
  );

  Widget fixedSize({double width, double height,}) => SizedBox(
    height: height,
    width: width,
    child: this,
  );
}