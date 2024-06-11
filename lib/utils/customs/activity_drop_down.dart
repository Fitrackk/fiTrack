import 'package:flutter/material.dart';

import '../../configures/color_theme.dart';

class ActivityDropDown extends StatefulWidget {
  final TextEditingController typeController;

  const ActivityDropDown({super.key, required this.typeController});

  @override
  State<ActivityDropDown> createState() => _ActivityDropDownState();
}

class _ActivityDropDownState extends State<ActivityDropDown> {
  String? _selectedActivity = 'Walking';

  @override
  void initState() {
    super.initState();
    widget.typeController.text = _selectedActivity!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        border: Border.all(color: FitColors.primary30, width: 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: FitColors.tertiary70,
          menuMaxHeight: 200,
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          value: _selectedActivity,
          onChanged: (String? newValue) {
            setState(() {
              _selectedActivity = newValue;
              widget.typeController.text = newValue!;
            });
          },
          items: <String>['Walking', 'Running', 'Jogging']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          underline: Container(
            height: 0,
          ),
        ),
      ),
    );
  }
}
