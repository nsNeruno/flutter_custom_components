import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActivityIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    if (Platform.isIOS) {
      return CupertinoActivityIndicator();
    }
    return CircularProgressIndicator();
  }
}