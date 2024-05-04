import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:flutter/material.dart';

class UserData extends StatelessWidget {
  const UserData({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back_ios_new),
            color: FitColors.tertiary60,
          ),
        ),
        body: const Center(child: DataForm()),
      ),
    );
  }
}

class DataForm extends StatefulWidget {
  const DataForm({super.key});

  @override
  _DataFormState createState() => _DataFormState();
}

class _DataFormState extends State<DataForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Transform.translate(
              offset: const Offset(0, -50),
              child: Text('Tell us about yourself',
                  style: TextStyles.headlineMedium
                      .copyWith(color: FitColors.text20)),
            ),
            Transform.translate(
              offset: const Offset(0, -45),
              child: Text('To give you a better experience',
                  style:
                      TextStyles.titlesmall.copyWith(color: FitColors.text20)),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle:
                    TextStyles.titleMedium.copyWith(color: FitColors.text10),
                hintText: 'Enter your username',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FitColors.tertiary60, // Standard border color
                    width: 1.1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FitColors
                        .primary30, // Color when the TextField is focused
                    width: 1.1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle:
                    TextStyles.titleMedium.copyWith(color: FitColors.text10),
                hintText: 'Enter your full name',
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FitColors.tertiary60,
                    width: 1.1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FitColors
                        .primary30, // Color when the TextField is focused
                    width: 1.1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      labelStyle: TextStyles.titleMedium
                          .copyWith(color: FitColors.text10),
                      hintText: 'John',
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FitColors.tertiary60,
                          width: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      labelStyle: TextStyles.titleMedium
                          .copyWith(color: FitColors.text10),
                      hintText: 'Doe',
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FitColors.tertiary60,
                          width: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateOfBirthController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: TextStyles.titleMedium
                        .copyWith(color: FitColors.text10),
                    hintText: 'Select your date of birth',
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FitColors.tertiary60,
                        width: 1.1,
                      ),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Gender: ',
                      style: TextStyles.labelmedium.copyWith(
                        color: FitColors.text10,
                      )),
                  const SizedBox(width: 10), // Space between label and dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FitColors.tertiary60,
                            width: 1.1,
                          ),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: <String>['Male', 'Female'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                      hint: const Text('Select Gender'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement your sign up logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FitColors.primary95,
                foregroundColor: FitColors.primary30,
                minimumSize: const Size(double.infinity,
                    50), // Makes the button taller and full-width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Border Radius
                ),
              ),
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed("signin");
                  },
                  child: const Text("Already have an account?"),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor:
                        FitColors.tertiary50, // Sets the text color to blue
                  ),
                  child: const Text("Sign In"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFBCD3DC), // Picker background color
              onPrimary: Color(0xFF233A43), // Text color
              surface: Color(0xFF79A8B9), // Picker background color
              onSurface: Color(0xFF233A43), // Text color
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFF233A43)), // Text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateOfBirthController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }
}
