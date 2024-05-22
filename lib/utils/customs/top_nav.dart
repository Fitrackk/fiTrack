import 'dart:math' as math;

import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/views/user_data_page.dart';
import 'package:flutter/material.dart';

class TopNav extends StatelessWidget implements PreferredSizeWidget {
  final int userLevel;
  final double userScore;

  const TopNav({super.key, this.userLevel = 15, this.userScore = 1580});

  @override
  Widget build(BuildContext context) {
    double progress = (userScore - (userLevel * 100)) / 100;
    if (progress > 1.0) {
      progress = 1.0;
    } else if (progress < 0) {
      progress = 0.0;
    }

    double startAngle = math.pi * 0.5;
    double sweepAngle = 2 * math.pi * progress;

    return AppBar(
      backgroundColor: FitColors.background,
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
                    MaterialPageRoute(builder: (context) => const UserData()),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: FitColors.background,
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 15,
                        backgroundImage: AssetImage('assets/images/logo.png'),
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
                bottom: -5,
                left: 20,
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
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 40),
            color: FitColors.primary30,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserData()),
              );
            },
          ),
        ],
      ),
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
