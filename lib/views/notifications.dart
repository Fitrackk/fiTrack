import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/utils/customs/notifications.dart';
import 'package:fitrack/view_models/reminders.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  NotificationsVm notification = NotificationsVm();

  String getCurrentDate() {
    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    String formattedDate = dateFormat.format(now);
    return formattedDate;
  }

  String getCurrentTime() {
    DateTime now = DateTime.now();
    DateFormat timeFormat = DateFormat('HH:mm');
    String formattedTime = timeFormat.format(now);
    return formattedTime;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double currentWidth = MediaQuery.of(context).size.width;
    int flag = 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: FitColors.primary30),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Notifications',
              style:
                  TextStyles.displaySmallBold.copyWith(color: FitColors.text20),
            ),
            SizedBox(height: 50),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: notification.getNotification(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final docs = snapshot.data!.docs;
                    final today = DateTime.now();

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final scheduledDate =
                            DateTime.parse(doc['scheduledDate']);
                        final difference = today.difference(scheduledDate);

                        if (difference.inDays <= 7) {
                          flag = 1;

                          return SizedBox(
                            width: currentWidth / 1.5,
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                if (doc['type'] == 'water')
                                  NotificationsCard(
                                    icon: const Icon(Icons.water_drop,
                                        size: 35, color: FitColors.text20),
                                    text: doc['body'],
                                    time: doc['scheduledDate'],
                                  ),
                                if (doc['type'] == 'challenge')
                                  NotificationsCard(
                                    icon: const ImageIcon(
                                      AssetImage('assets/images/challenge.png'),
                                      size: 35,
                                      color: FitColors.primary20,
                                    ),
                                    text: doc['body'],
                                    time: doc['scheduledDate'],
                                  ),
                                SizedBox(height: 15),
                                SizedBox(
                                  width: currentWidth / 1.2,
                                  child: Divider(
                                    thickness: 0.8,
                                    color: FitColors.primary30,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    );
                  }
                  Text('sssssssssssssssssssssssss $flag');
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
