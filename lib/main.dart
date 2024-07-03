import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medmate/firebase_options.dart';
import 'package:medmate/views/alarm_page.dart';
import 'package:medmate/views/login_page.dart';
import 'package:provider/provider.dart';
import 'package:medmate/enums.dart';
import 'views/WebSocket.dart';
import 'package:dcdg/dcdg.dart';
import 'package:medmate/menu_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var initializationSettingsAndroid = AndroidInitializationSettings('pill');
  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (payload) async {
    print("payload $payload");
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: LoginPage(),
      routes: {
        AlarmPage.routeName: (ctx) => AlarmPage(),
      },
    );
  }
}
