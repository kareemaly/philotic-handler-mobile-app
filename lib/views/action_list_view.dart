import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:philotic/constants/actions.dart';
import 'package:philotic/utils/get_key.dart';

class ActionListView extends StatelessWidget {
  void _deleteAction(String actionId) {
    Firestore.instance.collection("actions").document(actionId).setData(
      {
        "responded": true,
      },
      merge: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('actions')
          .where('action', isEqualTo: ADD_NOTIFICATION_ON_MY_MOBILE)
          .where('handled', isEqualTo: false)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading...');
          default:
            return new ListView(
              children:
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return new ListTile(
                  title: Text(document['action']),
                  subtitle: Text(
                    DateFormat("dd MMM, yyyy * HH:mm").format(
                      getKey<Timestamp>(
                        document.data,
                        "input.date",
                        Timestamp.now(),
                      ).toDate(),
                    ),
                  ),
                  leading: IconButton(
                    onPressed: () => _deleteAction(
                      document.documentID,
                    ),
                    icon: Icon(
                      Icons.done,
                    ),
                  ),
                );
              }).toList(),
            );
        }
      },
    );
  }
}
