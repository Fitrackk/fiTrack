// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String lableText;
  final IconButton? icon;
  final bool obScureText;
  const CustomTextField(
      {super.key,
        required this.lableText,
        required this.icon,
        required this.obScureText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 162, 157, 157),
              spreadRadius: 0.5,
              blurRadius: 10,
              offset: Offset(6, 4), // changes
            )
          ],
          color: Color.fromARGB(255, 240, 245, 248),
          borderRadius: BorderRadius.circular(50)),
      child: TextField(
        obscureText: obScureText,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: lableText,
          suffixIcon: icon,
          labelStyle: TextStyle(color: Color.fromARGB(255, 164, 191, 204)),
        ),
      ),
    );
  }
}
