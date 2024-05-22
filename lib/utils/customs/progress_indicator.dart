import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../configures/color_theme.dart';
import '../../configures/text_style.dart';

class CustomProgressIndicator extends StatefulWidget {
  final int defaultChallengeProgress;
  final int defaultChallengeSteps;
  final int defaultChallengeGoal;


  const CustomProgressIndicator(
      {super.key,
      required this.defaultChallengeProgress,
      required this.defaultChallengeSteps,
      required this.defaultChallengeGoal,
      });

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
                  "${widget.defaultChallengeProgress}%",
                  style:
                      TextStyles.titleLarge.copyWith(color: FitColors.text20),
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  "${widget.defaultChallengeSteps}",
                  style: TextStyles.displayLargeBold
                      .copyWith(color: FitColors.text20),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Steps Goal : ${widget.defaultChallengeGoal}",
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
