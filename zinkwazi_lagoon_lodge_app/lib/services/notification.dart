import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data_models/menuOrder.dart';
import 'dart:io' show Platform;


class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService(this.flutterLocalNotificationsPlugin) {
    // Init IOS specific permissions
    if (Platform.isIOS) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          .requestPermissions(
        alert: false,
        badge: true,
        sound: true,
      );
    }

    // Set platform specific settings.
    // * app_notification_icon needs to be a added as a drawable resource to the Android head project
    final initSettingAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettingIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async => onSelectNotification(payload),
    );

    // Init settings for Android + IOS
    //final initializationSettings = InitializationSettings(initSettingAndroid, initSettingIOS);
    final initializationSettings = InitializationSettings(android: initSettingAndroid, iOS: initSettingIOS);

    // Init flutterLocalNotificationsPlugin
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  // What happens when notification is pressed
  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  // Setting up notification details
  NotificationDetails get _general {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        ongoing: false,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    return NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

  }

  Future _showNotification({
    @required String title,
    @required String body,
    @required NotificationDetails details,
    int id = 0,
  }) => flutterLocalNotificationsPlugin.show(id, title, body, details);


  Future showPreparedNotification({
    @required MenuOrder order,
    int id = 0,
  }) async {
    _showNotification(
        title: 'Your order is ready!',
        body: '# ${order.dayId}',
        id: id,
        details: _general
    );
  }


}