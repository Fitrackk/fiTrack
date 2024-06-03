import 'package:flutter/material.dart';

import '../../configures/color_theme.dart';

class DatePicker extends StatefulWidget {
  final TextEditingController dateController;
  DatePicker({super.key, required this.dateController});

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: FitColors.tertiary80,
              onPrimary: FitColors.tertiary20,
              surface: FitColors.tertiary60,
              onSurface: FitColors.text10,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: FitColors.text10),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.dateController.text = "${_selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Text(
            '${_selectedDate.toLocal()}'.split(' ')[0],
          ),
        ),
      ],
    );
  }
}
