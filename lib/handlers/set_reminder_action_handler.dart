import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:philotic/utils/get_key.dart';

Future<void> setReminderActionHandler(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  DocumentSnapshot doc,
) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'PHILOTIC_REMINDERS',
    'Philotic Reminders',
    'Setting notification reminders from philoticWeb',
  );
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  NotificationDetails platformChannelSpecifics = NotificationDetails(
    androidPlatformChannelSpecifics,
    iOSPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.schedule(
    (DateTime.now().millisecondsSinceEpoch / 1000).floor(),
    getKey<String>(doc.data, "input.title", "No Title"),
    getKey<String>(doc.data, "input.body", "No Body"),
    getKey<Timestamp>(doc.data, "input.date", Timestamp.now()).toDate(),
    platformChannelSpecifics,
  );

  await Firestore.instance
      .collection("actions")
      .document(doc.documentID)
      .setData(
    {
      "handled": true,
    },
    merge: true,
  );
}
