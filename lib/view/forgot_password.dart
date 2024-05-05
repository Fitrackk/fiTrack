import 'package:fitrack/utils/customs/custom_text_field.dart';
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
  String _errorMessage = '';
  String _successMessage = '';


  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: FitColors.primary30,
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
                  color: FitColors.background,
                  child: Center(
                    child: Text(
                      "Forgot password",
                      style: TextStyles.titleLarge.copyWith(color: FitColors.primary30),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints.tightFor(width: 319, height: 60),
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
                CustomTextField(lableText: 'Email', icon: null, obScureText: false, myController: _emailController),
                const SizedBox(height: 5.0),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: FitColors.error50),
                ),
                Text(
                  _successMessage,
                  style: const TextStyle(color: FitColors.success50),
                ),
                const SizedBox(height: 5.0),
                Container(
                  width: 200,
                  height: 47,
                  decoration: BoxDecoration(
                    color: FitColors.primary30,
                    borderRadius: BorderRadius.circular(300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: MaterialButton(
                      onPressed: () async {
                        try {
                          await _viewModel.resetPassword(_emailController.text);
                          setState(() {
                            _successMessage = 'Password reset email has been sent';
                            _errorMessage ='';
                          });
                        } catch (e) {
                          setState(() {
                            _errorMessage = e.toString();
                            _successMessage ='';
                          });
                        }
                      },
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
