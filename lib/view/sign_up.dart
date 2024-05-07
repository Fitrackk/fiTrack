import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/utils/customs/custom_text_field.dart';
import 'package:fitrack/utils/customs/google_icon.dart';
import 'package:fitrack/view_model/sign_up.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    double currentWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: FitColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  "Sign Up",
                  style: TextStyles.displayLargeBold.copyWith(
                    color: FitColors.text30,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Enter profile details\n and start creating your account",
                  textAlign: TextAlign.center,
                  style: TextStyles.titleSmallbold.copyWith(
                    color: FitColors.text30,
                  ),
                ),
                const SizedBox(height: 50),
                CustomTextField(
                  labelText: 'Email',
                  showIcon: false,
                  obscureText: false,
                  myController: emailController,
                ),
                if (_authService.emailError.isNotEmpty)
                  Text(
                    _authService.emailError,
                    style: const TextStyle(color: FitColors.error40),
                  ),
                const SizedBox(height: 15),
                CustomTextField(
                  labelText: 'Password',
                  obscureText: true,
                  myController: passwordController,
                  showIcon: true,
                ),
                if (_authService.passwordError.isNotEmpty)
                  Text(
                    _authService.passwordError,
                    style: const TextStyle(color: FitColors.error40),
                  ),
                const SizedBox(height: 15),
                CustomTextField(
                  labelText: 'Confirm password',
                  obscureText: true,
                  myController: confirmPasswordController,
                  showIcon: true,
                ),
                if (_authService.confirmPasswordError.isNotEmpty)
                  Text(
                    _authService.confirmPasswordError,
                    style: const TextStyle(color: FitColors.error40),
                  ),
                const SizedBox(height: 15),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _authService.clearErrors();
                      _authService
                          .checkValidation(
                        context,
                        emailController.text,
                        passwordController.text,
                        confirmPasswordController.text,
                      )
                          .then((_) {
                        setState(() {});
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(FitColors.primary30),
                    ),
                    child: Text(
                      "Next",
                      style: TextStyles.titleMedium.copyWith(
                        color: FitColors.primary95,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Already have an account?   ",
                            style: TextStyles.labelLarge.copyWith(
                              color: FitColors.text30,
                            ),
                          ),
                          TextSpan(
                            text: " Sign in",
                            style: TextStyles.labelLarge.copyWith(
                              color: FitColors.tertiary50,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Navigator.pushNamed(context, '/signin');
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: currentWidth / 2.3,
                      child: const Divider(
                        thickness: 1.5,
                        color: FitColors.text30,
                        height: 50.0,
                      ),
                    ),
                    SizedBox(width: currentWidth / 50),
                    Text(
                      "OR",
                      style: TextStyles.titleMedBold
                          .copyWith(color: FitColors.text30),
                    ),
                    SizedBox(width: currentWidth / 50),
                    SizedBox(
                      width: currentWidth / 2.2,
                      child: const Divider(
                        thickness: 1.5,
                        color: FitColors.text30,
                        height: 50.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: currentWidth / 1.7,
                  child: ElevatedButton(
                    onPressed: () {
                      _authService.signUpWithGoogle(context);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(FitColors.primary99),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const GoogleLogo(),
                        const SizedBox(width: 15),
                        Text(
                          "SIGN UP WITH GOOGLE",
                          style: TextStyles.labelmedium
                              .copyWith(color: FitColors.text10),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
