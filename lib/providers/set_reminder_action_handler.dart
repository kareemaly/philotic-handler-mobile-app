import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:philotic/constants/actions.dart';
import 'package:philotic/utils/get_key.dart';

class SetReminderActionHandler extends StatefulWidget {
  final Widget child;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const SetReminderActionHandler({
    Key key,
    @required this.child,
    @required this.flutterLocalNotificationsPlugin,
  }) : super(key: key);

  @override
  _SetReminderActionHandlerState createState() =>
      _SetReminderActionHandlerState();
}

class _SetReminderActionHandlerState extends State<SetReminderActionHandler> {
  void _handleAction(DocumentSnapshot doc) async {
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
    await widget.flutterLocalNotificationsPlugin.schedule(
      (DateTime.now().millisecondsSinceEpoch/1000).floor(),
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

  @override
  void initState() {
    Firestore.instance
        .collection('actions')
        .where("action", isEqualTo: ADD_NOTIFICATION_ON_MY_MOBILE)
        .where("handled", isEqualTo: false)
        .snapshots()
        .listen((data) {
      data.documents.forEach(_handleAction);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
