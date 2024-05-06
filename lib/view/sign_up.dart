import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/utils/customs/custom_text_field.dart';
import 'package:fitrack/utils/customs/google_icon.dart';
import 'package:fitrack/view_model/sign_up.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController userName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Icon icon1 = const Icon(Icons.visibility, color: FitColors.primary30);
  Icon icon2 = const Icon(Icons.visibility, color: FitColors.primary30);
  bool obScureText1 = false;
  bool obScureText2 = false;
  int flag1 = 0;
  int flag2 = 0;

  @override
  void dispose() {
    userName.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

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
              const SizedBox(
                height: 40,
              ),
              Text("Sign Up",
                  style: TextStyles.displayLargeBold.copyWith(
                    color: FitColors.text30,
                  )),
              const SizedBox(
                height: 10,
              ),
              Text("Enter profile details\n and start creating your account",
                  textAlign: TextAlign.center,
                  style: TextStyles.titleSmallbold.copyWith(
                    color: FitColors.text30,
                  )),
              const SizedBox(
                height: 50,
              ),
              CustomTextField(
                lableText: "Email",
                icon: null,
                obScureText: false,
                myController: email,
              ),
              const SizedBox(
                height: 15,
              ),
              CustomTextField(
                lableText: "Password",
                icon: IconButton(
                  icon: icon1,
                  onPressed: () {
                    if (flag1 == 0) {
                      setState(() {
                        icon1 = const Icon(
                          Icons.visibility_off,
                          color: FitColors.text30,
                        );
                        obScureText1 = true;
                      });
                      flag1 = 1;
                    } else {
                      setState(() {
                        icon1 = const Icon(Icons.visibility,
                            color: FitColors.text30);
                        obScureText1 = false;
                      });
                      flag1 = 0;
                    }
                  },
                ),
                obScureText: obScureText1,
                myController: password,
              ),
              const SizedBox(
                height: 15,
              ),
              CustomTextField(
                lableText: "Confirm password",
                icon: IconButton(
                  icon: icon2,
                  onPressed: () {
                    if (flag2 == 0) {
                      setState(() {
                        icon2 = const Icon(
                          Icons.visibility_off,
                          color: FitColors.text30,
                        );
                        obScureText2 = true;
                      });
                      flag2 = 1;
                    } else {
                      setState(() {
                        icon2 = const Icon(
                          Icons.visibility,
                          color: FitColors.text30,
                        );
                        obScureText2 = false;
                      });
                      flag2 = 0;
                    }
                  },
                ),
                obScureText: obScureText2,
                myController: null,
              ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    signUp();
                    Navigator.pushReplacementNamed(context, '/user_data_form');
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
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center horizontally
                children: [
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Already have an account?   ",
                              style: TextStyles.labelLarge.copyWith(
                                color: FitColors.text30,
                              )),
                          TextSpan(
                            text: " Sign in",
                            style: TextStyles.labelLarge.copyWith(
                              color: FitColors.tertiary50,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, '/signin');
                              },
                          ),
                        ],
                      ),
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
                  SizedBox(
                    width: currentWidth / 50,
                  ),
                  Text(
                    "OR",
                    style: TextStyles.titleMedBold
                        .copyWith(color: FitColors.text30),
                  ),
                  SizedBox(
                    width: currentWidth / 50,
                  ),
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
              SizedBox(
                width: currentWidth / 1.5,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(FitColors.primary99),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const GoogleLogo(),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        "SIGN UP WITH GOOGLE",
                        style: TextStyles.labelmedium
                            .copyWith(color: FitColors.text10),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        )),
      ),
    );
  }

  void signUp() async {
    FirebaseAuthService auth = FirebaseAuthService();
    User? user =
        await auth.signUpWithEmailAndPassword(email.text, password.text);
    if (user == null) {
      if (kDebugMode) {
        print("NOT ADD");
      }
    } else {
      if (kDebugMode) {
        print("The New user added successfully");
      }
    }
  }
}