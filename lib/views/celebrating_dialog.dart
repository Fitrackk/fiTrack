import 'package:confetti/confetti.dart';
import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:flutter/material.dart';

class CelebratingDialog extends StatefulWidget {
  final String title;
  final String body;

  const CelebratingDialog({super.key, required this.title, required this.body});

  @override
  _CelebratingDialogState createState() => _CelebratingDialogState();
}

class _CelebratingDialogState extends State<CelebratingDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: FitColors.tertiary90,
      contentPadding: EdgeInsets.zero,
      content: Stack(
        children: [
          SizedBox(
            width: 300.0,
            height: 200.0,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: FitColors.primary30),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                      Colors.purple,
                    ],
                    createParticlePath: drawStar,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  style: TextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.body,
                  style: TextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Path drawStar(Size size) {
    double x = size.width / 2;
    double y = size.height / 2;
    return Path()
      ..moveTo(x, y - 5)
      ..lineTo(x + 5, y + 5)
      ..lineTo(x - 5, y + 5)
      ..close();
  }
}

void showCelebratingDialog(BuildContext context, String title, String body) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CelebratingDialog(title: title, body: body);
    },
  );
}
