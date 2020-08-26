import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime> showPlatformDatePicker({
  @required BuildContext context,
  @required DateTime initialDate,
  @required DateTime firstDate,
  @required DateTime lastDate,
  AndroidDatePickerOptions androidOptions,
  IosDateTimePickerOptions iosOptions,
}) {
  if (Platform.isIOS) {
    final Completer<DateTime> completer = Completer();
    DateTime selectedDate = initialDate;

    Widget buildCancelButton(BuildContext context,) {
      return iosOptions?.cancelButtonBuilder?.call(context,) ?? CupertinoButton(
        child: Text("Cancel",),
        onPressed: () {
          Navigator.of(context,).pop();
          completer.complete(null,);
        },
      );
    }

    Widget buildConfirmButton(BuildContext context,) {
      return iosOptions?.confirmButtonBuilder?.call(context,) ?? CupertinoButton(
        child: Text("Confirm",),
        onPressed: () {
          Navigator.of(context,).pop();
          completer.complete(selectedDate,);
        },
      );
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context,) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: const Radius.circular(4.0,),
              topLeft: const Radius.circular(4.0,),
            ),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iosOptions?.buttonBarBuilder?.call(
                context,
                buildCancelButton(context,),
                buildConfirmButton(context,),
              ) ?? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0,),
                child: Row(
                  children: [
                    buildCancelButton(context,),
                    Spacer(),
                    buildConfirmButton(context,),
                  ],
                ),
              ),
              SizedBox(
                height: () {
                  final height = MediaQuery.of(context,).size.height;
                  if (iosOptions?.heightRatio != null) {
                    return min(iosOptions.heightRatio, 1.0,) * height;
                  } else {
                    return IosDateTimePickerOptions._BASE_HEIGHT_RATIO * height;
                  }
                }(),
                child: CupertinoDatePicker(
                  onDateTimeChanged: (value) {
                    selectedDate = value;
                  },
                  initialDateTime: initialDate,
                  minimumDate: firstDate,
                  maximumDate: lastDate,
                  mode: CupertinoDatePickerMode.date,
                  minimumYear: firstDate.year,
                  maximumYear: lastDate.year,
                ),
              ),
            ],
          ),
        );
      },
    );

    return completer.future;
  }

  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    currentDate: androidOptions?.currentDate,
    initialEntryMode: androidOptions?.initialEntryMode ?? DatePickerEntryMode.calendar,
    selectableDayPredicate: androidOptions?.selectableDayPredicate,
    initialDatePickerMode: androidOptions?.initialDatePickerMode ?? DatePickerMode.day,
  );
}

@immutable
class AndroidDatePickerOptions {

  final DateTime currentDate;
  final DatePickerEntryMode initialEntryMode;
  final SelectableDayPredicate selectableDayPredicate;
  final DatePickerMode initialDatePickerMode;

  AndroidDatePickerOptions({
    this.currentDate,
    this.initialEntryMode = DatePickerEntryMode.calendar,
    this.selectableDayPredicate,
    this.initialDatePickerMode = DatePickerMode.day,
  });
}

typedef IosDateTimePickerButtonBarBuilder = Widget Function(BuildContext context, Widget cancelButton, Widget confirmButton,);

@immutable
class IosDateTimePickerOptions {

  static const _BASE_HEIGHT_RATIO = 0.25;

  final WidgetBuilder cancelButtonBuilder;
  final WidgetBuilder confirmButtonBuilder;
  final IosDateTimePickerButtonBarBuilder buttonBarBuilder;
  final double heightRatio;
  final int minuteInterval;
  final bool use24hFormat;

  IosDateTimePickerOptions({
    this.cancelButtonBuilder,
    this.confirmButtonBuilder,
    this.buttonBarBuilder,
    this.heightRatio = _BASE_HEIGHT_RATIO,
    this.minuteInterval = 1,
    this.use24hFormat = true,
  });
}

@immutable
class AndroidTimePickerOptions {

  final TimePickerEntryMode initialEntryMode;
  final String cancelText;
  final String confirmText;
  final String helpText;

  AndroidTimePickerOptions({
    this.initialEntryMode = TimePickerEntryMode.dial,
    this.cancelText = "Cancel",
    this.confirmText = "Confirm",
    this.helpText,
  });
}

Future<TimeOfDay> showPlatformTimePicker({
  @required BuildContext context,
  @required DateTime initialDate,
  AndroidTimePickerOptions androidOptions,
  IosDateTimePickerOptions iosOptions,
}) async {
  if (Platform.isIOS) {
    final Completer<TimeOfDay> completer = Completer();
    DateTime selectedDate = initialDate;

    Widget buildCancelButton(BuildContext context,) {
      return iosOptions?.cancelButtonBuilder?.call(context,) ?? CupertinoButton(
        child: Text("Cancel",),
        onPressed: () {
          Navigator.of(context,).pop();
          completer.complete(null,);
        },
      );
    }

    Widget buildConfirmButton(BuildContext context,) {
      return iosOptions?.confirmButtonBuilder?.call(context,) ??
          CupertinoButton(
            child: Text("Confirm",),
            onPressed: () {
              Navigator.of(context,).pop();
              completer.complete(TimeOfDay.fromDateTime(selectedDate,),);
            },
          );
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context,) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: const Radius.circular(4.0,),
              topLeft: const Radius.circular(4.0,),
            ),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iosOptions?.buttonBarBuilder?.call(
                context,
                buildCancelButton(context,),
                buildConfirmButton(context,),
              ) ?? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0,),
                child: Row(
                  children: [
                    buildCancelButton(context,),
                    Spacer(),
                    buildConfirmButton(context,),
                  ],
                ),
              ),
              SizedBox(
                height: () {
                  final height = MediaQuery
                      .of(context,)
                      .size
                      .height;
                  if (iosOptions?.heightRatio != null) {
                    return min(iosOptions.heightRatio, 1.0,) * height;
                  } else {
                    return IosDateTimePickerOptions._BASE_HEIGHT_RATIO * height;
                  }
                }(),
                child: CupertinoDatePicker(
                  onDateTimeChanged: (value) {
                    selectedDate = value;
                  },
                  initialDateTime: initialDate,
                  mode: CupertinoDatePickerMode.time,
                  minuteInterval: iosOptions?.minuteInterval ?? 1,
                  use24hFormat: iosOptions?.use24hFormat ?? true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  return showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate,),
    initialEntryMode: androidOptions?.initialEntryMode ?? TimePickerEntryMode.dial,
    cancelText: androidOptions?.cancelText ?? "Cancel",
    confirmText: androidOptions?.confirmText ?? "Confirm",
    helpText: androidOptions?.helpText,
  );
}

extension DateExtension on TimeOfDay {

  DateTime get dateTime {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, this.hour, this.minute,);
  }

  String get as24hColonFormattedString {
    final hour = this.hour.toString().padLeft(2, "0",);
    final minute = this.minute.toString().padLeft(2, "0",);
    return "$hour:$minute";
  }
}