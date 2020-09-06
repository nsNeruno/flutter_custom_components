import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class LoadingAlertDialog {

  static const UNSUPPORTED_PLATFORM = "UNSUPPORTED_PLATFORM";

  static WidgetBuilder _defaultWidgetBuilder;

  static void setDefaultWidgetBuilder(WidgetBuilder builder,) {
    if (builder != null) {
      _defaultWidgetBuilder = builder;
    }
  }

  static Future<T> showLoadingAlertDialog<T>({
    @required BuildContext context,
    @required Future<T> computation,
    WidgetBuilder builder,
  }) {
    final Completer<T> completer = Completer<T>();

    final WidgetBuilder builderWrapper = (context) {
      computation.then((value) {
        Navigator.of(context, rootNavigator: Platform.isIOS,).pop();
        if (Platform.isIOS) {
          Future.delayed( Duration(milliseconds: 50,), () {
            completer.complete(value,);
          },);
        } else {
          completer.complete(value,);
        }
      },).catchError((e,) {
        Navigator.of(context, rootNavigator: Platform.isIOS,).pop();
        if (Platform.isIOS) {
          Future.delayed( Duration(milliseconds: 50,), () {
            completer.completeError(e,);
          },);
        } else {
          completer.completeError(e,);
        }
      },);
      return WillPopScope(
        onWillPop: () async => false,
        child: _defaultWidgetBuilder?.call(context,) ?? builder?.call(context,) ?? Container(),
      );
    };

    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: builderWrapper,
      );
    } else if (Platform.isAndroid) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: builderWrapper,
      );
    } else {
      completer.completeError(UnsupportedError(UNSUPPORTED_PLATFORM,),);
    }

    return completer.future;
  }
}