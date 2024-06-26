import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:flutter/material.dart';

class StartedPage extends StatelessWidget {
  const StartedPage({super.key});

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
                width: 500,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Text('Explore more',
                    style: TextStyles.headlineLarge
                        .copyWith(color: FitColors.primary30)),
              ),
              Text('Each step a new horizon',
                  style:
                      TextStyles.titleMedium.copyWith(color: FitColors.text30)),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
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
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/signing'),
                child: Text(
                  "Sign In",
                  style: TextStyles.labelLargeBold
                      .copyWith(color: FitColors.text30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
