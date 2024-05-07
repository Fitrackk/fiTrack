import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? myController;
  final String labelText;
  bool obscureText;
  final bool showIcon;

  CustomTextField({
    Key? key,
    required this.labelText,
    required this.obscureText,
    required this.myController,
    required this.showIcon,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late Icon _icon;

  void _updateIcon() {
    _icon = widget.obscureText
        ? Icon(Icons.visibility_off, color: FitColors.primary30)
        : Icon(Icons.visibility, color: FitColors.primary30);
  }

  @override
  void initState() {
    super.initState();
    _updateIcon();
  }

  void _toggleObscureText() {
    setState(() {
      widget.obscureText = !widget.obscureText;
      _updateIcon();
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = TextStyles.bodysmall.copyWith(
      color: FitColors.placeholder,
    );
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: FitColors.placeholder,
            spreadRadius: 0.1,
            blurRadius: 6,
            offset: Offset(2, 4), // changes
          )
        ],
        color: FitColors.tertiary90,
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextField(
        controller: widget.myController,
        obscureText: widget.obscureText,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: widget.labelText,
          suffixIcon: widget.showIcon
              ? IconButton(
                  icon: _icon,
                  onPressed: _toggleObscureText,
                )
              : null,
          labelStyle: labelStyle,
        ),
      ),
    );
  }
}
