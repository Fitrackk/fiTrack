import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/view_models/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsVM()..fetchUserData(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Settings',
            style: TextStyles.titleLargeBold.copyWith(color: FitColors.text20),
          ),
        ),
        body: Consumer<SettingsVM>(
          builder: (context, viewModel, child) {
            final user = viewModel.user;
            if (user == null) {
              return Center(child: CircularProgressIndicator());
            }

            int userLevel = viewModel.calculateUserLevel(user.score as double);

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
                      Navigator.pushNamed(context, '/edit_profile');
                    },
                  ),
                  ListTile(
                    title: Text('Change Password',
                        style: TextStyles.labelMediumBold
                            .copyWith(color: FitColors.text20)),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: FitColors.primary30),
                    onTap: () {
                      Navigator.pushNamed(context, '/change_password');
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
