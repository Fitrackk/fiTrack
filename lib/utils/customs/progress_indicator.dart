import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../configures/color_theme.dart';
import '../../configures/text_style.dart';

//sample page
// class Dashboard extends StatefulWidget {
//   const Dashboard({super.key});
//
//   @override
//   _DashboardState createState() => _DashboardState();
// }
//
// class _DashboardState extends State<Dashboard> {
//   late Future<User?> _userDataFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _userDataFuture = UserVM().getUserData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: FitColors.background,
//       child: FutureBuilder<User?>(
//         future: _userDataFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const CircularProgressIndicator();
//           } else if (snapshot.hasError) {
//             return Text('Error: ${snapshot.error}');
//           } else {
//             final user = snapshot.data;
//             return displayUserData(user);
//           }
//         },
//       ),
//     );
//   }
//
//   Widget displayUserData(User? user) {
//     if (user != null) {
//       final String? username = user.userName;
//       final String? email = user.email;
//
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Welcome, $username!',
//             style: TextStyles.headlineMedium.copyWith(
//               color: FitColors.text20,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Email: $email',
//             style: TextStyles.labelLarge.copyWith(
//               color: FitColors.text20,
//             ),
//           ),
//         ],
//       );
//     } else {
//       return const Text('User data not found.');
//     }
//   }
// }
class CustomProgressIndicator extends StatefulWidget {
  const CustomProgressIndicator({super.key});

  @override
  State<CustomProgressIndicator> createState() =>
      _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<CustomProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "20%",
                  style:
                  TextStyles.titleLarge.copyWith(color: FitColors.text20),
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  "1582",
                  style: TextStyles.displayLargeBold
                      .copyWith(color: FitColors.text20),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Steps Goal : 10000",
                  style: TextStyles.titleLarge
                      .copyWith(color: FitColors.placeholder),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              child: StepProgressIndicator(
                currentStep: 1000,
                totalSteps: 10000,
                backgroundColor: const Color(0xFFBCD3DC),
                progressColor:
                const Color(0xFF176B87), // Progress color #176B87
              ),
            ),
          )
        ],
      ),
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color progressColor;

  StepProgressIndicator({
    required this.currentStep,
    required this.totalSteps,
    this.width = 200.0,
    this.height = 100.0,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    double progressPercentage = math.min(currentStep / totalSteps, 1.0);
    return CustomPaint(
      size: Size(width, height),
      painter: _ProgressPainter(
        progressPercentage: progressPercentage,
        backgroundColor: backgroundColor,
        progressColor: progressColor,
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progressPercentage;
  final Color backgroundColor;
  final Color progressColor;

  _ProgressPainter({
    required this.progressPercentage,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = size.width / 8;
    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    double radius = size.width / 1.2 - strokeWidth / 2;
    Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, backgroundPaint);
    // Adjust starting angle for 6 o'clock position (3 * PI / 2)
    double sweepAngle = 2 * math.pi * progressPercentage;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi / 2,
        sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
