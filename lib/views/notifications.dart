import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notifications').orderBy('scheduledDate').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              Timestamp scheduledTimestamp = notification['scheduledDate'];
              DateTime scheduledDateTime = scheduledTimestamp.toDate();
              String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(scheduledDateTime);

              return ListTile(
                title: Text(notification['title']),
                subtitle: Text(notification['body']),
                trailing: Text(formattedDate),
              );
            },
          );
        },
      ),
    );
  }
}