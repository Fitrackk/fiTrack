import 'dart:async';

import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  bool obscureText;
  final bool showIcon;

  CustomTextField({
    super.key,
    required this.labelText,
    required this.obscureText,
    required this.controller,
    required this.showIcon,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late Icon _icon;

  void _updateIcon() {
    _icon = widget.obscureText
        ? const Icon(Icons.visibility_off, color: FitColors.primary30)
        : const Icon(Icons.visibility, color: FitColors.primary30);
  }

  @override
  void initState() {
    super.initState();
    _updateIcon();
  }

  void _toggleObscureText() {
    setState(() {
      if (widget.obscureText) {
        widget.obscureText = false;
        _updateIcon();
        Timer(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              widget.obscureText = true;
              _updateIcon();
            });
          }
        });
      } else {
        widget.obscureText = true;
        _updateIcon();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = TextStyles.bodySmall.copyWith(
      color: FitColors.placeholder,
    );
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: FitColors.placeholder,
            spreadRadius: 0.1,
            blurRadius: 6,
            offset: Offset(2, 4),
          )
        ],
        color: FitColors.tertiary90,
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextField(
        cursorColor: FitColors.primary30,
        controller: widget.controller,
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
