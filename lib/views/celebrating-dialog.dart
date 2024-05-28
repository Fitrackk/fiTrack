import 'package:flutter/material.dart';

class CelebratingDialog extends StatelessWidget {
  const CelebratingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Congratulations!'),
      content: Container(
        width: 250.0,  // Set the width of the dialog
        height: 150.0,  // Set the height of the dialog
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Congrats! You completed the goal!'),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
