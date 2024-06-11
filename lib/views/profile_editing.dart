import 'package:device_info_plus/device_info_plus.dart';
import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/user_model.dart';
import '../view_models/edit_profile.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _fullNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final EditProfile _viewModel = EditProfile();

  User? _user;
  String? _profileImageUrl;
  String _usernameError = '';
  String _heightError = '';
  String _weightError = '';
  String _fullNameError = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _resetUserData() {
    if (_user != null) {
      setState(() {
        _fullNameController.text = _user!.fullName ?? '';
        _userNameController.text = _user!.userName ?? '';
        _heightController.text = _user!.height?.toString() ?? '';
        _weightController.text = _user!.weight?.toString() ?? '';
        _dateOfBirthController.text = _user!.dateOfBirth ?? '';
        _fullNameError = '';
        _usernameError = '';
        _heightError = '';
        _weightError = '';
      });
    }
  }

  Future<bool> requestPermission(Permission permission) async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    if (build.version.sdkInt >= 30) {
      var request = await Permission.manageExternalStorage.request();
      if (request.isGranted) {
        _pickImage();
        return true;
      } else {
        return false;
      }
    } else {
      if (await permission.isGranted) {
        return true;
      } else {
        var result = await permission.request();
        if (result.isGranted) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  Future<void> _loadUserData() async {
    User? user = await _viewModel.fetchUserData();
    if (user != null) {
      setState(() {
        _user = user;
        _fullNameController.text = user.fullName ?? '';
        _userNameController.text = user.userName ?? '';
        _heightController.text = user.height?.toString() ?? '';
        _weightController.text = user.weight?.toString() ?? '';
        _profileImageUrl = user.profileImageUrl;
        _dateOfBirthController.text = user.dateOfBirth ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String? downloadUrl =
          await _viewModel.uploadProfileImage(pickedFile.path);
      if (downloadUrl != null) {
        setState(() {
          _profileImageUrl = downloadUrl;
        });
        _user?.profileImageUrl = downloadUrl;
        _viewModel.updateUserData(_user!);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _userNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  void _onFullNameChanged(String value) async {
    String? error = await _viewModel.validateFullName(value);
    setState(() {
      _fullNameError = error ?? '';
    });
  }

  void _onHeightChanged(String value) async {
    String? error = await _viewModel.validateHeight(value);
    setState(() {
      _heightError = error ?? '';
    });
  }

  void _onWeightChanged(String value) async {
    String? error = await _viewModel.validateWeight(value);
    setState(() {
      _weightError = error ?? '';
    });
  }

  void _onUserNameChanged(String value) async {
    String? error = await _viewModel.validateUserName(value);
    setState(() {
      _usernameError = error ?? '';
    });
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Text(
                'Edit Profile',
                style:
                    TextStyles.titleLargeBold.copyWith(color: FitColors.text20),
              ),
              const SizedBox(height: 16.0),
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
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          if (await requestPermission(Permission.storage) ==
                              true) {
                            if (kDebugMode) {
                              print("Permission is granted");
                            }
                          } else {
                            if (kDebugMode) {
                              print("permission is not granted");
                            }
                          }
                        },
                        child: const CircleAvatar(
                          radius: 25,
                          backgroundColor: FitColors.primary30,
                          child: Icon(
                            Icons.mode_edit_outlined,
                            size: 30,
                            color: FitColors.tertiary95,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                style:
                    TextStyles.bodyMediumBold.copyWith(color: FitColors.text20),
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyles.titleMedBold
                      .copyWith(color: FitColors.placeholder),
                  errorText: _fullNameError.isNotEmpty ? _fullNameError : null,
                  errorStyle:
                      TextStyles.labelSmall.copyWith(color: FitColors.error40),
                  focusColor: FitColors.text20,
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: FitColors.tertiary60,
                        width: 2), // Change line color here
                  ),
                ),
                onChanged: _onFullNameChanged,
              ),
              const SizedBox(height: 16.0),
              TextField(
                style:
                    TextStyles.bodyMediumBold.copyWith(color: FitColors.text20),
                controller: _userNameController,
                decoration: InputDecoration(
                  labelText: 'User Name',
                  labelStyle: TextStyles.titleMedBold
                      .copyWith(color: FitColors.placeholder),
                  errorText: _usernameError.isNotEmpty ? _usernameError : null,
                  errorStyle:
                      TextStyles.labelSmall.copyWith(color: FitColors.error40),
                  focusColor: FitColors.text20,
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: FitColors.tertiary60,
                        width: 2), // Change line color here
                  ),
                ),
                onChanged: _onUserNameChanged,
              ),
              const SizedBox(height: 16.0),
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyles.bodyMediumBold
                          .copyWith(color: FitColors.text20),
                      controller: _heightController,
                      decoration: InputDecoration(
                        labelText: 'Height',
                        labelStyle: TextStyles.titleMedBold
                            .copyWith(color: FitColors.placeholder),
                        errorText:
                            _heightError.isNotEmpty ? _heightError : null,
                        errorStyle: TextStyles.labelSmall
                            .copyWith(color: FitColors.error40),
                        focusColor: FitColors.text20,
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: FitColors.tertiary60,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: _onHeightChanged,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyles.bodyMediumBold
                          .copyWith(color: FitColors.text20),
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: 'Weight',
                        labelStyle: TextStyles.titleMedBold
                            .copyWith(color: FitColors.placeholder),
                        errorText:
                            _weightError.isNotEmpty ? _weightError : null,
                        errorStyle: TextStyles.labelSmall
                            .copyWith(color: FitColors.error40),
                        focusColor: FitColors.text20,
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: FitColors.tertiary60,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: _onWeightChanged,
                    ),
                  ),
                  const SizedBox(height: 32.0),
                ],
              ),
              Center(
                child: Container(
                  alignment: Alignment.bottomCenter,
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
                            _resetUserData();
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
                            if (_user != null &&
                                _usernameError.isEmpty &&
                                _heightError.isEmpty &&
                                _weightError.isEmpty &&
                                _fullNameError.isEmpty) {
                              _user!.fullName = _fullNameController.text;
                              _user!.userName = _userNameController.text;
                              _user!.height =
                                  double.tryParse(_heightController.text);
                              _user!.weight =
                                  double.tryParse(_weightController.text);
                              _user!.dateOfBirth = _dateOfBirthController.text;
                              _viewModel.updateUserData(_user!);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Profile updated successfully',
                                  style: TextStyles.bodySmallBold
                                      .copyWith(color: FitColors.text95),
                                ),
                                backgroundColor: FitColors.tertiary50,
                              ),
                            );
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
