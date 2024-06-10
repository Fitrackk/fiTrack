import 'package:flutter/material.dart';

import '../configures/color_theme.dart';
import '../configures/text_style.dart';
import '../utils/customs/custom_text_field.dart';
import '../view_models/reset_password.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailController = TextEditingController();
  final ResetPasswordVM _viewModel = ResetPasswordVM();

  @override
  void dispose() {
    _emailController.dispose();
    _viewModel.clearErrors();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double currentWidth = MediaQuery.of(context).size.width;

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
                SizedBox(
                  width: currentWidth / 2,
                  // constraints:
                  //     const BoxConstraints.tightFor(width: 180, height: 51),
                  child: Center(
                    child: Text(
                      "Forgot password",
                      style: TextStyles.titleLarge
                          .copyWith(color: FitColors.primary30),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Container(
            constraints: const BoxConstraints.tightFor(width: 319, height: 60),
            child: Text(
              "Please enter your email to reset the password",
              style:
                  TextStyles.labelLarge.copyWith(color: FitColors.placeholder),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextField(
                  labelText: 'Email',
                  showIcon: false,
                  obscureText: false,
                  controller: _emailController,
                ),
                const SizedBox(height: 5.0),
                Text(
                  _viewModel.emailError,
                  style: const TextStyle(color: FitColors.error50),
                ),
                Text(
                  _viewModel.successMessage,
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
                        _viewModel.clearErrors();
                        await _viewModel
                            .resetPasswordWithEmail(_emailController.text);
                        setState(() {});
                      },
                      child: Text(
                        'Send',
                        style: TextStyles.labelLarge
                            .copyWith(color: FitColors.primary95),
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
