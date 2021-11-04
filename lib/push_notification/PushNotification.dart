import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libs/push_notification/MyFirebaseService.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  MyFirebaseService().showNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //ini berfungsi untuk menerima pesan dari firebase ketika aplikasi dibackground atau terminate
  //nggak ada akses untuk update UI dari sini. Itu tugas onMessage.listen
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //check if client is not web
  if (!kIsWeb) {
    MyFirebaseService().getToken().then((value) => print(value));
  }

  runApp(PushNotificationScreen());
}

class PushNotificationScreen extends StatelessWidget {
  const PushNotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: PushNotificationHome(),
    );
  }
}

class PushNotificationHome extends StatefulWidget {
  const PushNotificationHome({Key? key}) : super(key: key);

  @override
  _PushNotificationHomeState createState() => _PushNotificationHomeState();
}

class _PushNotificationHomeState extends State<PushNotificationHome> {
  String message = "";

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage){
      if(remoteMessage.data != null){
        MyFirebaseService().showNotification(remoteMessage);
        setState(() {
          message = remoteMessage.data["message"];
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase Messaging Example"),
      ),
      body: Center(
        child: Text(message),
      ),
    );
  }
}
