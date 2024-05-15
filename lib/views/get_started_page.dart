import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:flutter/material.dart';

class StartedPage extends StatelessWidget {
  const StartedPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              FitColors.primary30,
              FitColors.tertiary95,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/images/get_started.png",
                width: 500, // Adjust the width as needed
              ),
              const SizedBox(height: 10), // Space between image and text
              Padding(
                padding: EdgeInsets.only(bottom: 0),
                child: Text('Explore more',
                    style: TextStyles.headlineLarge
                        .copyWith(color: FitColors.primary30)),
              ),
              // Space between text elements
              Text('Each step a new horizon',
                  style:
                      TextStyles.titleMedium.copyWith(color: FitColors.text30)),
              const SizedBox(height: 60), // Space between text and button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FitColors.primary95,
                  minimumSize: const Size(380, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: Text("I'm new here",
                    style: TextStyles.titleMedium
                        .copyWith(color: FitColors.primary30)),
              ),
              // Space between button and sign in text

              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/signing'),
                child: const Text("Sign In",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: FitColors.text30)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
