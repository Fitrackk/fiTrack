import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitrack/utils/validation_utils/validation_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../configures/color_theme.dart';
import '../configures/text_style.dart';

class RegistrationVM extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';
  String _usernameError = '';
  String _fullNameError = '';
  String _heightError = '';
  String _weightError = '';
  String _genderError = '';
  String _dateOfBirthError = '';

  String get emailError => _emailError;

  String get passwordError => _passwordError;

  String get confirmPasswordError => _confirmPasswordError;

  String get usernameError => _usernameError;

  String get fullNameError => _fullNameError;

  String get heightError => _heightError;

  String get weightError => _weightError;

  String get genderError => _genderError;

  String get dateOfBirthError => _dateOfBirthError;

  void clearErrors() {
    _emailError = '';
    _passwordError = '';
    _confirmPasswordError = '';
    _usernameError = '';
    _fullNameError = '';
    _heightError = '';
    _weightError = '';
    _genderError = '';
    _dateOfBirthError = '';
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: googleSignInAccount.email)
            .get();

        if (userDoc.docs.isNotEmpty) {
          await _signInWithCredentialAndNavigate(
              context, credential, '/dashboard');
        } else {
          await _signInWithCredentialAndNavigate(
              context, credential, '/user_data_form');
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error signing in with Google',
            style: TextStyles.bodySmallBold.copyWith(
              color: FitColors.error40,
            )),
        backgroundColor: FitColors.tertiary50,
      ));
    }
  }

  Future<void> _signInWithCredentialAndNavigate(
      BuildContext context, AuthCredential credential, String route) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, route);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error signing in with credential: $error');
      }
    }
  }

  bool _validateField(String value, String errorField, String errorMessage) {
    if (value.isEmpty) {
      _setError(errorField, errorMessage);
      return false;
    }
    _setError(errorField, '');
    return true;
  }

  void _setError(String errorField, String errorMessage) {
    switch (errorField) {
      case 'email':
        _emailError = errorMessage;
        break;
      case 'password':
        _passwordError = errorMessage;
        break;
      case 'confirmPassword':
        _confirmPasswordError = errorMessage;
        break;
      case 'username':
        _usernameError = errorMessage;
        break;
      case 'fullname':
        _fullNameError = errorMessage;
        break;
      case 'height':
        _heightError = errorMessage;
        break;
      case 'weight':
        _weightError = errorMessage;
        break;
      case 'gender':
        _genderError = errorMessage;
        break;
      case 'dateOfBirth':
        _dateOfBirthError = errorMessage;
        break;
    }
    notifyListeners();
  }

  Future<bool> checkEmailUsing(String email) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return querySnapshot.docs.isEmpty;
  }

  Future<bool> validateEmail(String email) async {
    if (!_validateField(email, 'email', 'Email is required')) return false;
    if (!ValidationUtils.isValidEmail(email)) {
      _setError('email', 'Invalid email format');
      return false;
    }
    try {
      bool isUnique = await checkEmailUsing(email);
      if (!isUnique) {
        _setError('email', 'Email is already taken');
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error checking email uniqueness: $error');
      }
      _setError('email', 'Error checking email uniqueness');
      return false;
    }

    return true;
  }

  bool validatePassword(String password) {
    if (!_validateField(password, 'password', 'Password is required')) {
      return false;
    }
    if (!ValidationUtils.isValidPassword(password)) {
      _setError('password', 'Password must be at least 8 characters long');
      return false;
    }
    return true;
  }

  bool validateConfirmPassword(String confirmPassword, String password) {
    if (!_validateField(
        confirmPassword, 'confirmPassword', 'Confirm Password is required')) {
      return false;
    }
    if (confirmPassword != password) {
      _setError('confirmPassword', 'Passwords do not match');
      return false;
    } else if (!ValidationUtils.isValidPassword(confirmPassword)) {
      _setError(
          'confirmPassword', 'Password must be at least 8 characters long');
      return false;
    }
    return true;
  }

  Future<bool> checkUsernameUniqueness(String username) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return querySnapshot.docs.isEmpty;
  }

  Future<bool> validateUserName(String username) async {
    if (!_validateField(username, 'username', 'Username is required')) {
      return false;
    }
    if (username.length < 3) {
      _setError('username', 'Username must be at least 3 characters long');
      return false;
    }

    if (!ValidationUtils.isValidUserName(username)) {
      _setError('username', 'Username must not contain special characters');
      return false;
    }

    try {
      bool isUnique = await checkUsernameUniqueness(username);
      if (!isUnique) {
        _setError('username', 'Username is already taken');
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error checking username uniqueness: $error');
      }
      _setError('username', 'Error checking username uniqueness');
      return false;
    }

    return true;
  }

  bool validateFullName(String fullname) {
    if (!_validateField(fullname, 'fullname', 'Full Name is required')) {
      return false;
    }
    if (fullname.length < 2 || fullname.length > 40) {
      _setError(
          'fullname', 'Full name must be between 2 and 40 characters long');
      return false;
    }
    return true;
  }

  bool validateHeight(String height) {
    if (!_validateField(height, 'height', 'Height is required')) return false;
    double parsedHeight = double.tryParse(height) ?? 0.0;
    if (parsedHeight < 100 || parsedHeight > 250) {
      _setError('height', 'Please enter valid height');
      return false;
    }
    return true;
  }

  bool validateWeight(String weight) {
    if (!_validateField(weight, 'weight', 'Weight is required')) return false;
    double parsedWeight = double.tryParse(weight) ?? 0.0;
    if (parsedWeight < 21 || parsedWeight > 200) {
      _setError('weight', 'Please enter valid Weight');
      return false;
    }
    return true;
  }

  bool validateGender(String gender) {
    if (!_validateField(gender, 'gender', 'Gender is required')) return false;
    return true;
  }

  bool validateDateOfBirth(String dateOfBirth) {
    if (!_validateField(
        dateOfBirth, 'dateOfBirth', 'Date of Birth is required')) return false;
    return true;
  }

  int calculateAge(String dob) {
    DateTime today = DateTime.now();
    DateTime birthDate = DateTime.tryParse(dob) ?? today;
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<bool> storeUserData({
    required String username,
    required String fullname,
    required String height,
    required String weight,
    required String gender,
    required String dateOfBirth,
    required String email,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        int age = calculateAge(dateOfBirth);
        double parsedHeight = double.tryParse(height) ?? 0.0;
        double parsedWeight = double.tryParse(weight) ?? 0.0;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({
          'username': username,
          'fullName': fullname,
          'height': parsedHeight,
          'weight': parsedWeight,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
          'email': email,
          'score': 10,
          'age': age,
          'profileImageUrl':
              'https://firebasestorage.googleapis.com/v0/b/fitrack-ar138.appspot.com/o/profile_images%2Funknown.png?alt=media&token=b78193da-27d7-4aa6-b4ef-41f7b51c95e9',
          'waterReminder': "true",
          'challengeReminder': "true"
        });

        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error storing user data: $e');
      }
    }

    return false;
  }

  Future<void> checkValidation(BuildContext context, String email,
      String password, String confirmPassword) async {
    bool isEmailValid = await validateEmail(email);
    bool isPasswordValid = validatePassword(password);
    bool isConfirmPasswordValid =
        validateConfirmPassword(confirmPassword, password);

    if (isEmailValid && isPasswordValid && isConfirmPasswordValid) {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushNamed(
        context,
        '/user_data_form',
      );
    }
  }

  Future<void> signUp(
    BuildContext context,
    String fullName,
    String userName,
    String height,
    String weight,
    String gender,
    String dateOfBirth,
  ) async {
    bool isUserNameValid = await validateUserName(userName);
    bool isFullNameValid = validateFullName(fullName);
    bool isHeightValid = validateHeight(height);
    bool isWeightValid = validateWeight(weight);
    bool isGenderValid = validateGender(gender);
    bool isDateOfBirthValid = validateDateOfBirth(dateOfBirth);
    if (isUserNameValid &&
        isFullNameValid &&
        isHeightValid &&
        isWeightValid &&
        isGenderValid &&
        isDateOfBirthValid) {
      await createUserAccount(
        context,
        userName,
        fullName,
        height,
        weight,
        gender,
        dateOfBirth,
      );
    }
  }

  Future<void> createUserAccount(
    BuildContext context,
    String username,
    String fullName,
    String height,
    String weight,
    String gender,
    String dateOfBirth,
  ) async {
    try {
      User? user = _auth.currentUser;
      String? email = user?.email;
      if (email != null) {
        bool isUserDataStored = await storeUserData(
          username: username,
          fullname: fullName,
          height: height,
          weight: weight,
          gender: gender,
          dateOfBirth: dateOfBirth,
          email: email,
        );

        if (isUserDataStored) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to store user data',
                style: TextStyles.bodySmallBold
                    .copyWith(color: FitColors.error40)),
            backgroundColor: FitColors.tertiary50,
          ));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user: $e');
      }
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        _setError('email', 'Email is already in use');
      }
    }
  }
}
