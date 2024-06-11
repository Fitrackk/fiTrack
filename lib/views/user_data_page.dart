import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:flutter/material.dart';

import '../configures/routes.dart';
import '../view_models/registration.dart';

class UserData extends StatelessWidget {
  const UserData({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: Routes.getRoutes(context),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/signup');
            },
            icon: const Icon(Icons.arrow_back_ios_new),
            color: FitColors.tertiary60,
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          child: const DataForm(),
        ),
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
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  final RegistrationVM _authService = RegistrationVM();

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
              child: Text(
                'Tell us about yourself',
                style:
                    TextStyles.headlineMedium.copyWith(color: FitColors.text20),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -45),
              child: Text(
                'To give you a better experience',
                style: TextStyles.titleSmall.copyWith(color: FitColors.text20),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              onChanged: (value) {
                _authService.validateUserName(value);
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle:
                    TextStyles.titleMedium.copyWith(color: FitColors.text10),
                hintText: 'Enter your username',
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FitColors.tertiary60,
                    width: 1.1,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FitColors.primary30,
                    width: 1.1,
                  ),
                ),
              ),
            ),
            if (_authService.usernameError.isNotEmpty)
              Text(
                _authService.usernameError,
                style: const TextStyle(color: FitColors.error50),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: _fullNameController,
              onChanged: (value) {
                _authService.validateFullName(value);
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle:
                    TextStyles.titleMedium.copyWith(color: FitColors.text10),
                hintText: 'Enter your Full Name',
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FitColors.tertiary60,
                    width: 1.1,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FitColors.primary30,
                    width: 1.1,
                  ),
                ),
              ),
            ),
            if (_authService.fullNameError.isNotEmpty)
              Text(
                _authService.fullNameError,
                style: const TextStyle(color: FitColors.error50),
              ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: _heightController,
                        onChanged: (value) {
                          _authService.validateHeight(value);
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: 'Height',
                          labelStyle: TextStyles.titleMedium
                              .copyWith(color: FitColors.text10),
                          hintText: 'your height in cm',
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FitColors.tertiary60,
                              width: 1.1,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FitColors.primary30,
                              width: 1.1,
                            ),
                          ),
                        ),
                      ),
                      if (_authService.heightError.isNotEmpty)
                        Text(
                          _authService.heightError,
                          style: const TextStyle(color: FitColors.error50),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: _weightController,
                        onChanged: (value) {
                          _authService.validateWeight(value);
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: 'Weight',
                          labelStyle: TextStyles.titleMedium
                              .copyWith(color: FitColors.text10),
                          hintText: 'your weight in kg',
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FitColors.tertiary60,
                              width: 1.1,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FitColors.primary30,
                              width: 1.1,
                            ),
                          ),
                        ),
                      ),
                      if (_authService.weightError.isNotEmpty)
                        Text(
                          _authService.weightError,
                          style: const TextStyle(color: FitColors.error50),
                        ),
                    ],
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
                  onChanged: (value) {
                    _authService.validateDateOfBirth(value);
                    setState(() {});
                  },
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
            if (_authService.dateOfBirthError.isNotEmpty)
              Text(
                _authService.dateOfBirthError,
                style: const TextStyle(color: FitColors.error50),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Gender: ',
                    style: TextStyles.labelMedium.copyWith(
                      color: FitColors.text10,
                    ),
                  ),
                  const SizedBox(width: 10),
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
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FitColors.primary30,
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
            if (_authService.genderError.isNotEmpty)
              Text(
                _authService.genderError,
                style: const TextStyle(color: FitColors.error50),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _authService.clearErrors();
                _authService
                    .signUp(
                  context,
                  _fullNameController.text,
                  _usernameController.text,
                  _heightController.text,
                  _weightController.text,
                  _selectedGender ?? '',
                  _dateOfBirthController.text,
                )
                    .then((_) {
                  setState(() {});
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FitColors.primary30,
                foregroundColor: FitColors.primary95,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const InkWell(
                  child: Text("Already have an account?"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signing');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: FitColors.tertiary50,
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
      initialDate: DateTime(2016),
      firstDate: DateTime(1920),
      lastDate: DateTime(2016),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: FitColors.tertiary80,
              onPrimary: FitColors.tertiary20,
              surface: FitColors.tertiary60,
              onSurface: FitColors.text10,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: FitColors.text10),
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
