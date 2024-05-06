import 'package:flutter/material.dart';
import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/utils/customs/custom_text_field.dart';
import 'package:fitrack/view_model/sign_in.dart';
import 'package:provider/provider.dart';

class SignIn extends StatelessWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignInViewModel(), // Provide the SignInViewModel
      child: SignInContent(),
    );
  }
}

class SignInContent extends StatefulWidget {
  const SignInContent({Key? key}) : super(key: key);

  @override
  State<SignInContent> createState() => _SignInContentState();
}

class _SignInContentState extends State<SignInContent> {
  Icon icon1 = const Icon(Icons.visibility_off, color: FitColors.text30);
  bool obScureText1 = true;
  int flag1 = 0;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final signInVm = Provider.of<SignInViewModel>(context);

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
              if (signInVm.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(signInVm.errorMessage, style: const TextStyle(color: FitColors.error50)),
                ),
              CustomTextField(
                lableText: "Email or username",
                icon: null,
                obScureText: false,
                myController: emailController,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                lableText: "Password",
                icon: IconButton(
                  icon: icon1,
                  onPressed: () {
                    setState(() {
                      if (flag1 == 1) {
                        icon1 = const Icon(Icons.visibility, color: FitColors.text30);
                        obScureText1 = false;
                        flag1 = 0;
                      } else {
                        icon1 = const Icon(Icons.visibility_off, color: FitColors.text30);
                        obScureText1 = true;
                        flag1 = 1;
                      }
                    });
                  },
                ),
                obScureText: obScureText1,
                myController: passwordController,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, '/forget_password'),
                    child: Text("Forget password?", style: TextStyles.bodysmall.copyWith(color: FitColors.secondary10)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => signInVm.signIn(context, emailController.text, passwordController.text),
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
                onTap: () => Navigator.pushNamed(context, '/signup'),
                child: const Text("Sign up", style: TextStyle(decoration: TextDecoration.underline, color: FitColors.text30)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
