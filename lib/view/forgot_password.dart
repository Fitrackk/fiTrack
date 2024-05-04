import 'dart:io';
import 'package:flutter/material.dart';
import '../configures/color_theme.dart';
import '../configures/text_style.dart';
import '../view_model/forgot_password.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  final ForgotPasswordViewModel _viewModel = ForgotPasswordViewModel();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _passwordReset() async {
    String email = _emailController.text.trim();

    try {
      await _viewModel.resetPassword(email);
      _showDialog('Password reset email has been sent to $email');
    } catch (e) {
      _showDialog(e.toString());
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => exit(0),
          color: FitColors.text30,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints.tightFor(width: 180, height: 51),
                  color: FitColors.background, // Adding background color to the container
                  child: Center(
                    child: Text(
                      "Forgot password",
                      style: TextStyles.titleLarge.copyWith(color: FitColors.text30),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints.tightFor(width: 319, height: 150),
            child: Text(
              "Please enter your email to reset the password",
              style: TextStyles.labelLarge.copyWith(color: FitColors.placeholder),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                const SizedBox(height: 20),
                Container(
                  width: 320,
                  height: 47,
                  decoration: BoxDecoration(
                    color: FitColors.primary30,
                    borderRadius: BorderRadius.circular(300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                    child: MaterialButton(
                      onPressed: _passwordReset,
                      child: Text(
                        'Send',
                        style: TextStyles.labelLarge.copyWith(color: FitColors.primary95),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
