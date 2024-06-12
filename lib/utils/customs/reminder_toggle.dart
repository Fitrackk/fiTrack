import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../configures/color_theme.dart';

class ReminderToggle extends StatefulWidget {
  final TextEditingController reminderController;

  const ReminderToggle({super.key, required this.reminderController});

  @override
  State<ReminderToggle> createState() => _ReminderToggleState();
}

class _ReminderToggleState extends State<ReminderToggle> {
  bool _remindersEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Switch(
            value: _remindersEnabled,
            onChanged: (bool value) {
              setState(() {
                _remindersEnabled = value;
                widget.reminderController.text = _remindersEnabled.toString();
                if (kDebugMode) {
                  print(widget.reminderController.text);
                }
              });
            },
            activeColor: FitColors.primary20,
            activeTrackColor: FitColors.tertiary60,
            inactiveThumbColor: FitColors.primary20,
            inactiveTrackColor: FitColors.tertiary40,
          ),
        ),
        SizedBox(
          width: 1,
          height: 1,
          child: TextField(
            controller: widget.reminderController,
            enabled: false,
          ),
        ),
      ],
    );
  }
}
