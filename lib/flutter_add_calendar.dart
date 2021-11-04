import 'dart:async';

import 'package:flutter/services.dart';

class FlutterAddCalendar {
  static const MethodChannel _channel =
      const MethodChannel('flutter_add_calendar/native');

  static FlutterAddCalendar? _instance;
  final _onStatusAdd = new StreamController<StatusCalendar>.broadcast();

  factory FlutterAddCalendar() => _instance ??= new FlutterAddCalendar._();

  Stream<StatusCalendar> get onStatusAdd => _onStatusAdd.stream;

  void dispose() {
    _onStatusAdd.close();
    _instance = null;
  }

//  static void setEventToCalendar({Map<String, dynamic> event}) {
//    _channel.invokeMethod('setEventToCalendar', event);
//  }

  //Map with list key: title, desc, startDate, endDate, alert (dateString, alert: timestamp like millisecond)
  Future<Null> setEventToCalendar(Map<String, String> event) async {
    await _channel.invokeMethod('setEventToCalendar', event);
  }

  FlutterAddCalendar._() {
    _channel.setMethodCallHandler(_handleMessages);
  }

  Future<Null> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case 'receiveStatus':
        _onStatusAdd.add(
            StatusCalendar(call.arguments['code'], call.arguments['message']));
        break;
    }
  }

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

class StatusCalendar {
  final String? code;
  final String? message;

  StatusCalendar(this.code, this.message);
}

class EventInfo {
  final String? title;
  final String? desc;
  final String? location;
  final String? startDate;
  final String? endDate;

  EventInfo(
      {this.title, this.desc, this.startDate, this.endDate, this.location});
}
