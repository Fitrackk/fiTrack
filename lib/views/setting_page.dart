import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/view_models/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool challengeReminder = true;
  bool waterReminder = true;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsVM()..fetchUserData(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Settings',
            style: TextStyles.titleLargeBold.copyWith(color: FitColors.text20),
          ),
        ),
        body: Consumer<SettingsVM>(
          builder: (context, viewModel, child) {
            final user = viewModel.user;
            if (user == null) {
              return const Center(child: Text(' '));
            }

            int userLevel = viewModel.calculateUserLevel(user.score ?? 0);

            challengeReminder = user.challengeReminder == 'true';
            waterReminder = user.waterReminder == 'true';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.profileImageUrl != null
                            ? NetworkImage(user.profileImageUrl!)
                            : const AssetImage('assets/images/p.png')
                                as ImageProvider,
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName ?? 'unknown',
                            style: TextStyles.labelLarge
                                .copyWith(color: FitColors.text20),
                          ),
                          Text(
                            'Level $userLevel',
                            style: TextStyles.labelLarge
                                .copyWith(color: FitColors.text20),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Icon(Icons.person, color: FitColors.primary30),
                      const SizedBox(width: 8),
                      Text(
                        'Account',
                        style: TextStyles.labelLargeBold
                            .copyWith(color: FitColors.text20),
                      ),
                    ],
                  ),
                  const Divider(
                    color: FitColors.placeholder,
                    thickness: 1,
                  ),
                  ListTile(
                    title: Text('Edit Profile',
                        style: TextStyles.labelMediumBold
                            .copyWith(color: FitColors.text20)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: FitColors.primary30),
                    onTap: () {
                      Navigator.pushNamed(context, '/edit_profile');
                    },
                  ),
                  ListTile(
                    title: Text('Change Password',
                        style: TextStyles.labelMediumBold
                            .copyWith(color: FitColors.text20)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: FitColors.primary30),
                    onTap: () {
                      Navigator.pushNamed(context, '/change_password');
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.notifications,
                          color: FitColors.primary30),
                      const SizedBox(width: 8),
                      Text(
                        'Notifications',
                        style: TextStyles.labelLargeBold
                            .copyWith(color: FitColors.text20),
                      ),
                    ],
                  ),
                  const Divider(
                    color: FitColors.placeholder,
                    thickness: 1,
                  ),
                  ListTile(
                    title: Text('Challenge Reminder',
                        style: TextStyles.labelMediumBold
                            .copyWith(color: FitColors.text20)),
                    trailing: Switch(
                      value: challengeReminder,
                      onChanged: (value) {
                        setState(() {
                          challengeReminder = value;
                          viewModel.updateChallengeReminder(value);
                        });
                      },
                      activeColor: FitColors.primary20,
                      activeTrackColor: FitColors.tertiary60,
                      inactiveThumbColor: FitColors.primary20,
                      inactiveTrackColor: FitColors.tertiary40,
                    ),
                  ),
                  ListTile(
                    title: Text('Water Reminder',
                        style: TextStyles.labelMediumBold
                            .copyWith(color: FitColors.text20)),
                    trailing: Switch(
                      value: waterReminder,
                      onChanged: (value) {
                        setState(() {
                          waterReminder = value;
                          viewModel.updateWaterReminder(value);
                        });
                      },
                      activeColor: FitColors.primary20,
                      activeTrackColor: FitColors.tertiary60,
                      inactiveThumbColor: FitColors.primary20,
                      inactiveTrackColor: FitColors.tertiary40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                    color: FitColors.placeholder,
                    thickness: 1,
                  ),
                  ListTile(
                    title: Text('Log Out',
                        style: TextStyles.labelMediumBold
                            .copyWith(color: FitColors.text20)),
                    trailing:
                        const Icon(Icons.logout, color: FitColors.primary30),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              dialogBackgroundColor: FitColors.tertiary90,
                            ),
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              content: Text(
                                '\nAre you sure you want to log out?',
                                style: TextStyles.bodyLarge
                                    .copyWith(color: FitColors.text20),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: FitColors.primary30,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: TextStyles.labelMediumBold
                                        .copyWith(color: FitColors.text95),
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: FitColors.primary30,
                                  ),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await viewModel.logOut();
                                    navigatorKey.currentState!
                                        .pushReplacementNamed('/signing');
                                  },
                                  child: Text(
                                    'Log Out',
                                    style: TextStyles.labelMediumBold
                                        .copyWith(color: FitColors.text95),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
