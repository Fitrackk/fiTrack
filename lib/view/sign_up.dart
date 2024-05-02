import 'package:fitrack/utils/customs/custom_text_feild.dart';
import 'package:fitrack/utils/customs/google_icon.dart';
import 'package:flutter/material.dart';


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  Icon icon1 =  const Icon(Icons.visibility, color: Colors.blueAccent);
  Icon icon2 =  const Icon(Icons.visibility, color: Colors.blueAccent);
  bool obScureText1 = false;
  bool obScureText2 = false;
  int flag1 = 0;
  int flag2 = 0;

  @override
  Widget build(BuildContext context) {
    double currentWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Color.fromARGB(255, 27, 114, 185),
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Enter profile details\n and start creating your account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 30,
                      ),
                      Container(
                        width: 165,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.blue),
                            foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.facebook_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Facebook",
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Container(
                        width: 165,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GoogleLogo(),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "Google",
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: currentWidth / 2.2,
                        child: const Divider(
                          thickness: 2.0,
                          color: Colors.grey,
                          height: 50.0,
                        ),
                      ),
                      SizedBox(
                        width: currentWidth / 120,
                      ),
                      const Text(
                        "OR",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        width: currentWidth / 120,
                      ),
                      Container(
                        width: currentWidth / 2.2,
                        child: const Divider(
                          thickness:
                          2.0, // Adjust thickness as needed (default is 0.0)
                          color: Colors
                              .grey, // Adjust color as needed (default is null)
                          height: 50.0, // Adjust height as needed (default is 16.0)
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const CustomTextField(
                      lableText: "Username",
                      icon: null,
                      obScureText: false
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const CustomTextField(
                      lableText: "Email",
                      icon: null,
                      obScureText: false
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                   CustomTextField(
                      lableText: "Password",
                      icon:IconButton(
                        icon: icon1,
                        onPressed: () {
                          if (flag1 == 0) {
                            setState(() {
                              icon1 = const Icon(
                                Icons.visibility_off,
                                color: Colors.blueAccent,
                              );
                              obScureText1 = true;
                            });

                            flag1 = 1;
                          } else {
                            setState(() {
                              icon1 =
                                  const Icon(Icons.visibility, color: Colors.blueAccent);
                              obScureText1 = false;
                            });
                            flag1 = 0;
                          }
                        },
                      ),
                    obScureText: obScureText1,
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
                                color: Colors.blueAccent,
                              );
                              obScureText2 = true;
                            });
                            flag2 = 1;
                          } else {
                            setState(() {
                              icon2 =
                                  const Icon(Icons.visibility, color: Colors.blueAccent);
                              obScureText2 = false;
                            });
                            flag2 = 0;
                          }
                        },
                      ),
                    obScureText: obScureText2,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text("Next"),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 245, 243, 243)),
                        foregroundColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 150, 148, 148)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed("signup");
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Already have account?\n ",
                            style: TextStyle(color: Colors.blue, fontSize: 15),
                          ),
                          TextSpan(
                            text: "Sign in",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
