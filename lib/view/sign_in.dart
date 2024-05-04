import 'package:flutter/material.dart';
import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/utils/customs/custom_text_feild.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _obscureText = true; // State to manage visibility of password

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText; // Toggle between true and false
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
              const SizedBox(height: 5),  // Reduced height from 40 to 20
              Text("Sign in", style: TextStyles.displayLargeBold.copyWith(color: FitColors.text30)),
              const SizedBox(height: 50),
              Text("Welcome back again", style: TextStyles.titleMedium.copyWith(color: FitColors.text30)),
              const SizedBox(height: 60),
              const CustomTextField(
                lableText: "Email or username",
                icon: null,
                obScureText: false,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                lableText: "Password",
                icon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: _togglePasswordVisibility,
                ),
                obScureText: _obscureText,
              ),
              const SizedBox(height: 20 ),

              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: InkWell(
                    onTap: _onForgetPasswordTap,
                    child: Text(
                      "Forget password",
                      style: TextStyles.bodysmall.copyWith(color: FitColors.secondary10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  // Implement your sign in logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FitColors.primary95,
                  foregroundColor: FitColors.primary30,
                  minimumSize: const Size(380, 60,), // Makes the button taller and full-width
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40), // Border Radius
                  ),
                ),
                child:  Text('Login' , style: TextStyles.titleMedium.copyWith(color: FitColors.primary30)),
              ),
              const SizedBox(height: 40,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text("Don’t have an account?" , style: TextStyles.labelLarge.copyWith(color: FitColors.text30),),
              ),
              GestureDetector(
                onTap: () {}, // Add navigation to your signup screen here
                child: Text("Sign up", style: TextStyle(decoration: TextDecoration.underline, color: FitColors.text30)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onForgetPasswordTap() {
  }
}
