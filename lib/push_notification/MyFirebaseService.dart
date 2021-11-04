import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyFirebaseService {
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  MyFirebaseService() {
    _createNotificationChannel();
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();
    print("background Message");
    print(message);
  }

  Future<void> _createNotificationChannel() async {
    channel = AndroidNotificationChannel("channel_id", "channe_name",
        description: "channel desriptions", importance: Importance.high);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
  }

  void showNotification(RemoteMessage remoteMessage) {
    RemoteNotification? notification = remoteMessage.notification;
    Map<String, dynamic> data = remoteMessage.data;
    if (notification != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        1,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name,
              icon: 'launch_background'),
        ),
      );
    } else {
      flutterLocalNotificationsPlugin.show(
        1,
        data["dari"],
        data["message"],
        NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name,
              icon: 'launch_background'),
        ),
      );
    }
  }

  Future<String?> getToken() {
    return FirebaseMessaging.instance.getToken();
  }
}
