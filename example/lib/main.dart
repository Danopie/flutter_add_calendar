import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_add_calendar/flutter_add_calendar.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  FlutterAddCalendar flutterAddCalendar = new FlutterAddCalendar();
  StreamSubscription<StatusCalendar> _onStatusAdd;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    _onStatusAdd =
        flutterAddCalendar.onStatusAdd.listen((StatusCalendar status) {
      print("New status ${status.code} ${status.message}");
    });
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onStatusAdd.cancel();
    flutterAddCalendar.dispose();

    super.dispose();
  }

  Future<void> initPlatformState() async {
    print("call initPlatformState");
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app add calendar'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              RaisedButton(
                child: Text("Add event"),
                onPressed: () {
                  Map<String, String> event = {
                    "title": "event add calendar",
                    "desc": "test add event to canlendar of device",
                    "startDate": "${DateTime.now().millisecondsSinceEpoch}",
                    "endDate":
                        "${DateTime.now().millisecondsSinceEpoch + Duration(hours: 2).inMilliseconds}",
                    "alert": "180000"
                  };
                  flutterAddCalendar.setEventToCalendar(event);
                },
              ),
              RaisedButton(
                child: Text("Silently add event"),
                onPressed: () {
                  Map<String, String> event = {
                    "silently": "true",
                    "title": "event add calendar",
                    "desc": "test add event to canlendar of device",
                    "startDate":
                        "${DateTime.now().add(Duration(days: 1)).toUtc().millisecondsSinceEpoch}",
                    "endDate":
                        "${DateTime.now().add(Duration(days: 1)).toUtc().millisecondsSinceEpoch + Duration(hours: 2).inMilliseconds}",
                    "alert": "180000"
                  };
                  flutterAddCalendar.setEventToCalendar(event);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
