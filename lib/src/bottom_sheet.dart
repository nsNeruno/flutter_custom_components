import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef WidgetListBuilder = List<Widget> Function(BuildContext context,);

Future<T> showModalBottomActionSheet<T>({
  @required BuildContext context,
  WidgetBuilder titleBuilder,
  WidgetBuilder messageBuilder,
  WidgetListBuilder actionsBuilder,
  WidgetListBuilder iosActionsBuilder,
  WidgetBuilder cancelButtonBuilder,
  double maxHeight,
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  VoidCallback onClosing,
  bool cancelButtonOnBothPlatform = false,
}) {

  Widget buildCancelButton(BuildContext context,) {
    final cancelButton = cancelButtonBuilder?.call(context,);
    if (cancelButton != null) {
      if (cancelButton is CupertinoActionSheetAction) {
        if (Platform.isIOS) {
          return cancelButton;
        } else {
          return FlatButton(
            onPressed: cancelButton.onPressed,
            child: cancelButton.child,
          );
        }
      } else if (cancelButton is MaterialButton) {
        if (Platform.isIOS) {
          return CupertinoActionSheetAction(
            child: cancelButton.child,
            onPressed: cancelButton.onPressed,
          );
        } else { return cancelButton; }
      } else if (cancelButton is GestureDetector) {
        if (Platform.isIOS) {
          return CupertinoActionSheetAction(
            child: cancelButton.child,
            onPressed: cancelButton.onTap,
          );
        } else { return cancelButton; }
      } else return cancelButton;
    }
    return Container();
  }
  
  if (Platform.isIOS) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: titleBuilder?.call(context,),
        message: messageBuilder?.call(context,),
        actions: iosActionsBuilder?.call(context,),
        cancelButton: buildCancelButton(context,),
      ),
    );
  } else {
    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: onClosing ?? () => {},
        builder: (context) => Container(
          constraints: maxHeight != null && maxHeight >= 0.0 ? BoxConstraints.loose(
            Size.fromHeight(maxHeight,),
          ) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: crossAxisAlignment,
            children: <Widget>[
              titleBuilder?.call(context) ?? Container(),
              messageBuilder?.call(context) ?? Container(),
              ...(actionsBuilder?.call(context,) ?? []),
              cancelButtonOnBothPlatform == true ? buildCancelButton(context,) : Container(),
            ],
          ),
        ),
      ),
    );
  }
}