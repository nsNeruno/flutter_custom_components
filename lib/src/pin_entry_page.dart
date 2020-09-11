import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

typedef NumericKeyWidgetBuilder = Widget Function(BuildContext context, int pinDigit,);
typedef OnPinChanged = void Function(BuildContext context, String currentPin,);
typedef OnPinSubmitted = void Function(BuildContext context, String pinDigits, VoidCallback reset,);

const PIN_LENGTH = 6;

class PinEntryPage extends StatefulWidget {

  final String initialPinDigits;
  final Widget appBar;
  final Color backgroundColor;
  final EdgeInsetsGeometry contentPadding;
  final Widget top;
  final NumericKeyWidgetBuilder pinSlotBuilder;
  final double pinSlotPadding;
  final WidgetBuilder emptyPinSlotBuilder;
  final Widget middle;
  final bool useDeviceKeyboard;
  final NumericKeyWidgetBuilder numericKeyBuilder;
  final WidgetBuilder deleteKeyBuilder;
  final Widget bottom;
  final OnPinChanged onPinChanged;
  final OnPinSubmitted onPinSubmitted;

  const PinEntryPage({
    Key key,
    this.initialPinDigits,
    this.appBar,
    this.backgroundColor,
    this.contentPadding,
    this.top,
    this.pinSlotBuilder,
    this.pinSlotPadding = 8.0,
    this.emptyPinSlotBuilder,
    this.middle,
    this.useDeviceKeyboard = false,
    this.numericKeyBuilder,
    this.deleteKeyBuilder,
    this.bottom,
    this.onPinChanged,
    this.onPinSubmitted,
  }) : super(key: key);

  @override
  PinEntryPageState createState() => PinEntryPageState();
}

class PinEntryPageState extends State<PinEntryPage> with WidgetsBindingObserver {

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.useDeviceKeyboard == true) {
      switch (state) {
        case AppLifecycleState.resumed:
          _hiddenNode.requestFocus();
          Future.delayed(Duration(milliseconds: 100,), () {
            _forceOpenKeyboard();
          },);
          break;
        case AppLifecycleState.inactive:
          _forceHideKeyboard();
          break;
        case AppLifecycleState.paused:
          _forceHideKeyboard();
          break;
        case AppLifecycleState.detached:
          _forceHideKeyboard();
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this,);

    if (widget.initialPinDigits != null &&
        widget.initialPinDigits.length <= PIN_LENGTH &&
        int.tryParse(widget.initialPinDigits,) != null) {
      _pinDigits.value = widget.initialPinDigits;
    }

    if (widget.useDeviceKeyboard == true) {
      _hiddenController = TextEditingController();
      _hiddenNode = FocusNode();

      _keyboardEventSubscriptionId = KeyboardVisibilityNotification().addNewListener(
        onChange: _onKeyboardVisibilityChange,
      );

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _hiddenNode.requestFocus();
      },);
    }
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        _isPopped = true;
        if (_keyboardEventSubscriptionId != null) {
          isListeningToKeyboardEvents = false;
        }
        return true;
      },
      child: Stack(
        children: <Widget>[
          widget.useDeviceKeyboard == true ? _InvisibleTextField(
            controller: _hiddenController,
            focusNode: _hiddenNode,
            onDigitAdded: (value) => _onPinKeyPressed(value?.toString(),),
          ) : Container(),
          Scaffold(
            appBar: widget.appBar,
            backgroundColor: widget.backgroundColor,
            body: SafeArea(
              child: Padding(
                padding: widget.contentPadding ?? EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          widget.top ?? Container(),
                          ValueListenableBuilder(
                            valueListenable: _pinDigits,
                            builder: (_, value, __) => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                6, (index) {
                                  final currentPin = _pinDigits.value;
                                  Widget pinSlot;
                                  if (index < currentPin.length) {
                                    final pinDigit = int.tryParse(currentPin[index]);
                                    if (widget.pinSlotBuilder != null && pinDigit != null) {
                                      pinSlot = widget.pinSlotBuilder(context, pinDigit,);
                                    } else {
                                      pinSlot = Text(currentPin[index],);
                                    }
                                  } else {
                                    pinSlot = widget.emptyPinSlotBuilder?.call(context,) ?? Text("_",);
                                  }
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: widget.pinSlotPadding,),
                                    child: pinSlot,
                                  );
                                },
                              ),
                            ),
                          ),
                          widget.middle ?? Container(),
                        ],
                      ),
                    ),
                    widget.useDeviceKeyboard == true ? Container() : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(
                          3, (rIndex) => Row(
                            children: List.generate(
                              3, (cIndex) {
                                final digit = 3 * rIndex + cIndex + 1;
                                return Expanded(
                                  child: FlatButton(
                                    shape: CircleBorder(),
                                    child: widget.numericKeyBuilder?.call(context, digit,) ?? Text(digit.toString(),),
                                    onPressed: () => _onPinKeyPressed(digit.toString(),),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Spacer(),
                            Expanded(
                              child: FlatButton(
                                shape: CircleBorder(),
                                child: widget.numericKeyBuilder?.call(context, 0,) ?? Text("0",),
                                onPressed: () => _onPinKeyPressed("0",),
                              ),
                            ),
                            Expanded(
                              child: FlatButton(
                                shape: CircleBorder(),
                                child: widget.deleteKeyBuilder?.call(context,) ?? Icon(Icons.backspace,),
                                onPressed: () => _onPinKeyPressed(null,),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    widget.bottom ?? Container(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isPopped = true;
    _forceHideKeyboard();
    _pinDigits.dispose();

    _hiddenController?.dispose();
    _hiddenNode?.dispose();

    if (_keyboardEventSubscriptionId != null) {
      KeyboardVisibilityNotification().removeListener(
        _keyboardEventSubscriptionId,);
    }
    super.dispose();
  }

  final ValueNotifier<String> _pinDigits = ValueNotifier("",);
  TextEditingController _hiddenController;
  FocusNode _hiddenNode;

  int _keyboardEventSubscriptionId;

  bool _isListeningToKeyboardEvents = true;
  bool get isListeningToKeyboardEvents => _isListeningToKeyboardEvents;
  bool _isPopped = false;

  String get pinDigits => _pinDigits.value;

  void _forceOpenKeyboard() {
    if (Platform.isIOS) {
      _hiddenNode.requestFocus();
      return;
    }
    SystemChannels.textInput.invokeMethod("TextInput.show",);
  }

  void _forceHideKeyboard() {
    if (Platform.isIOS) {
      _hiddenNode.unfocus();
      return;
    }
    SystemChannels.textInput.invokeMethod("TextInput.hide",);
  }

  void _onPinKeyPressed(String digit,) {
    final currentPin = _pinDigits.value;
    if (digit == null && currentPin.isNotEmpty) {
      if (currentPin.isNotEmpty) {
        _pinDigits.value = currentPin.substring(0, currentPin.length - 1,);
        widget.onPinChanged?.call(context, _pinDigits.value,);
      }
      return;
    }

    if (digit.isEmpty) { return; }

    if (currentPin.length < PIN_LENGTH) {
      _pinDigits.value = "$currentPin${digit[0]}";
      widget.onPinChanged?.call(context, _pinDigits.value,);
    } else if (currentPin.length == PIN_LENGTH) {
      widget.onPinSubmitted?.call(context, _pinDigits.value, _reset,);
    }
  }

  void _reset() {
    _pinDigits.value = "";
  }

  void _onKeyboardVisibilityChange(bool isVisible) {
    if (!isVisible) {
      if (!_isPopped) {
        Future.delayed(Duration(milliseconds: 150,), () {
          _forceOpenKeyboard();
        },);
      }
    }
  }

  set isListeningToKeyboardEvents(bool value,) {
    _isListeningToKeyboardEvents = value;
    if (_isListeningToKeyboardEvents) {
      _keyboardEventSubscriptionId = KeyboardVisibilityNotification().addNewListener(
        onChange: _onKeyboardVisibilityChange,
      );
    } else {
      if (_keyboardEventSubscriptionId != null) {
        KeyboardVisibilityNotification().removeListener(
          _keyboardEventSubscriptionId,);
      }
    }
  }

  void reset() => _reset();
}

class _InvisibleTextField extends StatelessWidget {

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<int> onDigitAdded;

  const _InvisibleTextField({
    Key key,
    this.controller,
    this.focusNode,
    this.onDigitAdded,
  }) : super(key: key,);

  @override
  Widget build(BuildContext context) {

    return Material(
      child: Opacity(
        opacity: 0.0,
        child: TextField(
          autofocus: true,
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {},
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              final incomingText = newValue.text.trim();
              String digit;
              if (incomingText.length >= 1) {
                digit = incomingText[0];
              }
              onDigitAdded?.call(int.tryParse(digit ?? "",),);
              return newValue.copyWith(text: " ", selection: TextSelection.collapsed(offset: 1,),);
            },),
          ],
        ),
      ),
    );
  }
}

Future<T> showPinEntryModalBottomSheet<T>({
  @required BuildContext context,
  double heightFactor = 0.4,
  String initialPinDigits,
  Widget appBar,
  Color backgroundColor,
  EdgeInsetsGeometry contentPadding,
  Widget top,
  NumericKeyWidgetBuilder pinSlotBuilder,
  double pinSlotPadding = 8.0,
  WidgetBuilder emptyPinSlotBuilder,
  Widget middle,
  bool useDeviceKeyboard = false,
  NumericKeyWidgetBuilder numericKeyBuilder,
  WidgetBuilder deleteKeyBuilder,
  Widget bottom,
  OnPinChanged onPinChanged,
  OnPinSubmitted onPinSubmitted,
}) {
  if (heightFactor == null || heightFactor < 0.0) {
    heightFactor = 0.4;
  }
  if (heightFactor > 1.0) {
    heightFactor = 1.0;
  }
  return showModalBottomSheet<T>(
    context: context,
    builder: (context) {
      return Container(
        constraints: BoxConstraints(
          minWidth: double.infinity,
          minHeight: MediaQuery.of(context,).size.height * heightFactor,
        ),
        child: PinEntryPage(
          initialPinDigits: initialPinDigits,
          appBar: appBar,
          backgroundColor: backgroundColor,
          contentPadding: contentPadding,
          top: top,
          pinSlotBuilder: pinSlotBuilder,
          pinSlotPadding: pinSlotPadding,
          emptyPinSlotBuilder: emptyPinSlotBuilder,
          middle: middle,
          useDeviceKeyboard: useDeviceKeyboard,
          numericKeyBuilder: numericKeyBuilder,
          deleteKeyBuilder: deleteKeyBuilder,
          bottom: bottom,
          onPinChanged: onPinChanged,
          onPinSubmitted: onPinSubmitted,
        ),
      );
    },
  );
}