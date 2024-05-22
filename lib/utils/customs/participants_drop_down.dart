import 'package:fitrack/configures/color_theme.dart';
import 'package:flutter/material.dart';

class ParticipantsDropDown extends StatefulWidget {
  final TextEditingController participantsController;

  const ParticipantsDropDown({super.key, required this.participantsController});

  @override
  State<ParticipantsDropDown> createState() => _ParticipantsDropDownState();
}

class _ParticipantsDropDownState extends State<ParticipantsDropDown> {
  String? _selectedParticipants = '7';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          focusColor: FitColors.tertiary70,
          dropdownColor: FitColors.tertiary70,
          menuMaxHeight: 150,
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          value: _selectedParticipants,
          onChanged: (String? newValue) {
            setState(() {
              _selectedParticipants = newValue;
              if (newValue != null) {
                widget.participantsController.text = newValue;
              }
            });
          },
          items: <String>['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
