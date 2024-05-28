import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/view_models/settings.dart';
import 'package:fitrack/views/change_password_page.dart';
import 'package:fitrack/views/edit_profile_page.dart';

class SettingsPage extends StatefulWidget {
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
              return Center(child: Text(' '));
            }

            int userLevel = viewModel.calculateUserLevel(user.score as double);

            challengeReminder = user.challengeReminder == 'true';
            waterReminder = user.waterReminder == 'true';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.profileImageUrl != null
                            ? NetworkImage(user.profileImageUrl!)
                            : AssetImage('assets/images/p.png')
                        as ImageProvider,
                      ),
                      SizedBox(width: 20),
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
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.person, color: FitColors.primary30),
                      SizedBox(width: 8),
                      Text(
                        'Account',
                        style: TextStyles.labelLargeBold
                            .copyWith(color: FitColors.text20),
                      ),
                    ],
                  ),
                  Divider(
                    color: FitColors.placeholder,
                    thickness: 1,
                  ),
                  ListTile(
                    title: Text('Edit Profile',
                        style: TextStyles.labelMediumBold
                            .copyWith(color: FitColors.text20)),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: FitColors.primary30),
                    onTap: () {
                      // Navigate to Edit Profile Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProfilePage()),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Change Password',
                        style: TextStyles.labelMediumBold
                            .copyWith(color: FitColors.text20)),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: FitColors.primary30),
                    onTap: () {
                      // Navigate to Change Password Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangePasswordPage()),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.notifications, color: FitColors.primary30),
                      SizedBox(width: 8),
                      Text(
                        'Notifications',
                        style: TextStyles.labelLargeBold
                            .copyWith(color: FitColors.text20),
                      ),
                    ],
                  ),
                  Divider(
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
