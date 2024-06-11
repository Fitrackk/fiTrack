import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/customs/custom_text_field.dart';
import '../utils/validation_utils/validation_utils.dart';
import '../view_models/change_password.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ChangePasswordVM _viewModel = ChangePasswordVM();

  String _oldPasswordError = '';
  String _newPasswordError = '';
  String _confirmPasswordError = '';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfileImageUrl();
  }

  Future<void> _loadUserProfileImageUrl() async {
    try {
      String? imageUrl = await _viewModel.getUserProfileImageUrl();
      if (imageUrl != null && imageUrl.isNotEmpty) {
        setState(() {
          _profileImageUrl = imageUrl;
        });
      } else {
        setState(() {
          _profileImageUrl = 'assets/images/unknown.png';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user profile image: $e');
      }
      setState(() {
        _profileImageUrl = 'assets/images/unknown.png';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
          color: FitColors.tertiary60,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Text(
                    'Change Password',
                    style: TextStyles.titleLargeBold
                        .copyWith(color: FitColors.text20),
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : const AssetImage('assets/images/unknown.png')
                                as ImageProvider,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40.0),
                CustomTextField(
                  labelText: 'Old Password',
                  showIcon: true,
                  obscureText: true,
                  controller: _oldPasswordController,
                ),
                const SizedBox(height: 8.0),
                Center(
                  child: Text(
                    _oldPasswordError,
                    style: const TextStyle(color: FitColors.error40),
                  ),
                ),
                const SizedBox(height: 8.0),
                CustomTextField(
                  labelText: 'New Password',
                  showIcon: true,
                  obscureText: true,
                  controller: _newPasswordController,
                ),
                const SizedBox(height: 8.0),
                Center(
                  child: Text(
                    _newPasswordError,
                    style: const TextStyle(color: FitColors.error40),
                  ),
                ),
                const SizedBox(height: 8.0),
                CustomTextField(
                  labelText: 'Confirm New Password',
                  showIcon: true,
                  obscureText: true,
                  controller: _confirmPasswordController,
                ),
                const SizedBox(height: 8.0),
                Center(
                  child: Text(
                    _confirmPasswordError,
                    style: const TextStyle(color: FitColors.error40),
                  ),
                ),
                const SizedBox(height: 32.0),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FitColors.tertiary90,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyles.labelLargeBold
                                .copyWith(color: FitColors.text20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32.0),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FitColors.primary30,
                          ),
                          onPressed: () {
                            _validateAndChangePassword();
                          },
                          child: Text(
                            'Save',
                            style: TextStyles.labelLargeBold
                                .copyWith(color: FitColors.text95),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _validateAndChangePassword() async {
    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    bool isValid = true;
    bool isOldPasswordValid = await _viewModel.validateOldPassword(oldPassword);
    setState(() {
      _oldPasswordError = '';
      _newPasswordError = '';
      _confirmPasswordError = '';
    });
    if (oldPassword.isEmpty) {
      setState(() {
        _oldPasswordError = 'Old password is required';
      });
      isValid = false;
      return;
    }
    if (!isOldPasswordValid) {
      setState(() {
        _oldPasswordError = 'Incorrect old password';
      });
      isValid = false;
      return;
    }

    if (newPassword.isEmpty) {
      setState(() {
        _newPasswordError = 'New password is required';
      });
      isValid = false;
      return;
    }
    if (newPassword == oldPassword) {
      setState(() {
        _newPasswordError =
            'New password must be different from the old password';
      });
      isValid = false;
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Please confirm your new password';
      });
      isValid = false;
      return;
    } else if (newPassword != confirmPassword) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      isValid = false;
      return;
    }
    if (!ValidationUtils.isValidPassword(newPassword)) {
      setState(() {
        _newPasswordError = 'Password must be at least 8 characters long';
      });
      isValid = false;
      return;
    }
    if (isValid) {
      _viewModel.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password changed successfully',
            style: TextStyles.bodySmallBold.copyWith(color: FitColors.text95),
          ),
          backgroundColor: FitColors.tertiary50,
        ),
      );
      Navigator.pop(context);
    }
  }
}
