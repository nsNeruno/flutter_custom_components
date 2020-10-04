import 'package:flutter/material.dart';
import 'package:flutter_custom_components/flutter_custom_components.dart';

void main() {
  runApp(TestApp(),);
}

class TestApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: "Soluix Flutter Components",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TestPage(),
    );
  }}

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Test App",)
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            child: Text("Test Loading Alert Dialog",),
            onPressed: _testLoadingAlertDialog,
          ).maxWidth,
          RaisedButton(
            child: Text("Open PIN Page",),
            onPressed: _openPinPage,
          ).maxWidth,
          RaisedButton(
            child: Text("Test Date Picker",),
            onPressed: _pickDate,
          ),
          RaisedButton(
            child: Text("Test Time Picker",),
            onPressed: _pickTime,
          ),
        ],
      ).paddedAll(24.0,),
    );
  }

  void _testLoadingAlertDialog() {
    LoadingAlertDialog.showLoadingAlertDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              color: Colors.white,
              child: SizedBox.fromSize(
                size: Size.square(24.0,),
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
      computation: Future.delayed( Duration(seconds: 3,), ),
    );
  }

  void _openPinPage() {
    Navigator.of(context,).push(
      MaterialPageRoute(
        builder: (context) {
//          Future.delayed(Duration(seconds: 5,), () {
//            Navigator.of(context).push(
//              MaterialPageRoute(builder: (_) => TestPage(),),
//            );
//          },);
          return PinEntryPage(
            appBar: AppBar(
              title: Text("PIN Page",),
            ),
            useDeviceKeyboard: true,
          );
        },
      ),
    );
  }

  void _pickDate() {
    final now = DateTime.now();
    showPlatformDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(Duration(days: 30,),),
      lastDate: now.add(Duration(days: 30,),),
    ).then((date) {
      debugPrint(date.toString(),);
    },);
  }

  void _pickTime() {
    final now = DateTime.now();
    showPlatformTimePicker(
      context: context,
      initialDate: now,
    ).then((time) {
      debugPrint(time.toString(),);
    });
  }
}