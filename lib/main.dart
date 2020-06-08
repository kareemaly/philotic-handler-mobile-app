import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:philotic/handlers/set_reminder_action_handler.dart';
import 'package:philotic/constants/actions.dart';

Future<FlutterLocalNotificationsPlugin>
    initializeFlutterLocationNotificationsPlugin() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings(
    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: selectNotification,
  );
  return flutterLocalNotificationsPlugin;
}

Query getNotificationQuery() {
  return Firestore.instance
      .collection('actions')
      .where("action", isEqualTo: ADD_NOTIFICATION_ON_MY_MOBILE)
      .where("handled", isEqualTo: false);
}

void backgroundFetchHeadlessTask(String taskId) async {
  print('[Flutter] [Background Fetch] Headless event received.');

  final flutterLocalNotificationsPlugin =
      await initializeFlutterLocationNotificationsPlugin();
  final data = await getNotificationQuery().getDocuments();

  final futures = data.documents
      .map(
        (doc) => setReminderActionHandler(
          flutterLocalNotificationsPlugin,
          doc,
        ),
      )
      .toList();

  await Future.wait(futures);

  BackgroundFetch.finish(taskId);
}

void main() async {
  runApp(MyApp());
  final flutterLocalNotificationsPlugin =
      await initializeFlutterLocationNotificationsPlugin();

  // Listen for any actions and pass it to be handled
  getNotificationQuery().snapshots().listen((data) {
    data.documents.forEach(
      (doc) => setReminderActionHandler(
        flutterLocalNotificationsPlugin,
        doc,
      ),
    );
  });

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

Future selectNotification(String payload) async {
  if (payload != null) {
    debugPrint('notification payload: ' + payload);
  }
}

Future onDidReceiveLocalNotification(
  int id,
  String title,
  String body,
  String payload,
) async {
  if (payload != null) {
    debugPrint('notification payload: ' + payload);
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        forceAlarmManager: false,
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,
      ),
      (taskId) => print("[Flutter] [BackgroundFetch.15] is called $taskId"),
    ).then((int status) {
      print('[Flutter] [BackgroundFetch] configure success: $status');
    }).catchError((e) {
      print('[Flutter ][BackgroundFetch] configure ERROR: $e');
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Text("Philotic Mobile App Handler"),
      ),
    );
  }
}
