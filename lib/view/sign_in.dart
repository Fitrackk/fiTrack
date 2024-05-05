import 'package:flutter/material.dart';
import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/utils/customs/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _obscureText = true;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  String _errorMessage = '';

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              Text("Sign in", style: TextStyles.displayLargeBold.copyWith(color: FitColors.text30)),
              const SizedBox(height: 50),
              Text("Welcome back again", style: TextStyles.titleMedium.copyWith(color: FitColors.text30)),
              const SizedBox(height: 30),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: const TextStyle(color: FitColors.error50, fontSize: 16)),
              const SizedBox(height: 10),


              CustomTextField(
                lableText: "Email or username",
                icon: null,
                obScureText: false,
                myController: email,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                lableText: "Password",
                icon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: FitColors.primary30),
                  onPressed: _togglePasswordVisibility,
                ),
                obScureText: _obscureText,
                myController: password,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: InkWell(
                    onTap: _onForgetPasswordTap,
                    child: Text("Forget password?", style: TextStyles.bodysmall.copyWith(color: FitColors.secondary10)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email.text.trim(),
                      password: password.text.trim(),
                    );
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  } on FirebaseAuthException catch (e) {
                    setState(() {
                      _errorMessage = 'Incorrect email or password';
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FitColors.primary30,
                  minimumSize: const Size(380, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: Text('Sign in', style: TextStyles.titleMedium.copyWith(color: FitColors.primary95)),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text("Don’t have an account?", style: TextStyles.labelLarge.copyWith(color: FitColors.text30)),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text("Sign up", style: TextStyle(decoration: TextDecoration.underline, color: FitColors.text30)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onForgetPasswordTap() {
    Navigator.pushNamed(context, '/forget_password');
  }
}
