import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/utils/customs/notification_card.dart';
import 'package:fitrack/view_models/get_reminders.dart';
import 'package:fitrack/views/no_notification_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  NotificationsVM notification = NotificationsVM();

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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: FitColors.primary30),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Notifications',
              style:
                  TextStyles.displaySmallBold.copyWith(color: FitColors.text20),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: FutureBuilder<List<QueryDocumentSnapshot>>(
                future: notification.getNotification(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerCard(context);
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final docs = snapshot.data!;
                    if (docs.isEmpty) {
                      return const NoNotification();
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
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
                              const SizedBox(height: 15),
                              SizedBox(
                                width: currentWidth / 1.2,
                                child: const Divider(
                                  thickness: 0.8,
                                  color: FitColors.primary30,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const NoNotification();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(left: 30),
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              color: Colors.white,
            ),
            const SizedBox(width: 20),
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 80,
                        height: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
