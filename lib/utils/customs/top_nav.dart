import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../configures/color_theme.dart';
import '../../view_models/top_nav.dart';
import '../../views/notifications.dart';

class TopNav extends StatelessWidget implements PreferredSizeWidget {
  final TopNavViewModel _viewModel = TopNavViewModel();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _viewModel.fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppBar(
            automaticallyImplyLeading: false,
            title: Text(' '),
          );
        } else {
          if (snapshot.hasError || snapshot.data == null) {
            return AppBar(
              automaticallyImplyLeading: false,
              title: Text('Error fetching data'),
            );
          }

          final userData = snapshot.data!;
          final int userScore = userData['score'] ?? 0;
          int userLevel = ((userScore / 100) + 1).toInt();
          if (userScore < 100) userLevel = 1;
          final profileImageUrl =
              userData['profileImageUrl'] as String?; // Cast to String or null
          final profileImage = profileImageUrl != null
              ? NetworkImage(profileImageUrl)
              : AssetImage('assets/images/unknown.png');

          double progress = (userScore % 100) / 100;
          if (progress > 1.0) {
            progress = 1.0;
          } else if (progress < 0) {
            progress = 0.0;
          }

          // Calculate start and sweep angles for progress arc
          double startAngle = math.pi * 0.5;
          double sweepAngle = 2 * math.pi * progress;

          return AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificationPage()),
                        );
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.transparent,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: profileImage as ImageProvider,
                            ),
                            Positioned.fill(
                              child: CustomPaint(
                                painter: ProgressPainter(
                                  startAngle: startAngle,
                                  sweepAngle: sweepAngle,
                                  color: FitColors.primary30,
                                  strokeWidth: 5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -1,
                      left: 34,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: FitColors.background,
                        ),
                        child: Text(
                          userLevel.toString(),
                          style: const TextStyle(
                            color: FitColors.primary30,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none, size: 40),
                  color: FitColors.primary30,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationPage()),
                    );
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ProgressPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final Color color;
  final double strokeWidth;

  ProgressPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
