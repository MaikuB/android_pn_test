import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Push Notifications Test'),
      ),
      body: Center(
        child: _notificationButtons(context),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _notificationButtons(BuildContext context) {
    final data = Map<String, dynamic>.from({
      "notId": 'notificationId',
      "goKey": 'card1',
      "type": 'notifications',
      "title": 'Internal title',
      "body": 'Some stuff goes here',
    });

    final payload = Map<String, dynamic>.from({
      ...data,
      "data": data,
    });

    return Column(
      children: [
        FlatButton(
          child: Text('Test notifications'),
          onPressed: () => _showNotification(payload),
        ),
      ],
    );
  }

  dynamic _initialize() async {
    final initializationSettingsAndroid =
        const AndroidInitializationSettings('icon');
    final initializationSettingsIOS = const IOSInitializationSettings(
      defaultPresentAlert: true,
    );
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  dynamic _showNotification(Map<String, dynamic> notification) async {
    try {
      final androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'all_notifications',
        'General Notifications',
        'General Notifications',
        playSound: true,
        enableVibration: true,
        importance: Importance.max,
        priority: Priority.high,
      );
      final iOSPlatformChannelSpecifics = const IOSNotificationDetails();
      final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      final payload = _setupNotificationPayload(
        notification: jsonDecode(jsonEncode(notification)),
      );

      final String title = payload['title'];
      final String body = payload['body'];

      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: jsonEncode(payload),
      );
    } catch (error) {
      print(error);
    }
  }

  Map<String, dynamic> _setupNotificationPayload({
    @required Map<String, dynamic> notification,
  }) {
    final type = "notifications";
    var notificationId = "";
    var goKey = "";
    var title = "";
    var body = "";

    if (Platform.isIOS) {
      var data = notification;

      notificationId = notification['notId'];
      goKey = notification['goKey'];

      if (notification.containsKey('aps')) data = notification['aps']['alert'];

      title = data['title'];
      body = data['body'];
    } else if (Platform.isAndroid) {
      final data = notification['data'];

      notificationId = data['notId'];
      goKey = data['goKey'];
      title = data['title'];
      body = data['msgText'] ?? data['body'];
    }

    return {
      "notificationId": notificationId,
      "goKey": goKey,
      "type": type,
      "title": title,
      "body": body,
    };
  }
}
