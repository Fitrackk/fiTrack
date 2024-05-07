import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? myController;
  final String lableText;
  final IconButton? icon;
  final bool obScureText;

  CustomTextField(
      {super.key,
      required this.lableText,
      required this.icon,
      required this.obScureText,
      required this.myController});

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = TextStyles.bodysmall.copyWith(
      color: FitColors.placeholder,
    );
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: FitColors.placeholder,
          spreadRadius: 0.1,
          blurRadius: 6,
          offset: Offset(2, 4), // changes
        )
      ], color: FitColors.primary100, borderRadius: BorderRadius.circular(50)),
      child: TextField(
        controller: myController,
        obscureText: obScureText,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: lableText,
          suffixIcon: icon,
          labelStyle: labelStyle,
        ),
      ),
    );
  }
}
