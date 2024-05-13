import 'package:fitrack/configures/BottomNavBloc.dart';
import 'package:flutter/material.dart';
import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/views/dashboard_page.dart';
import 'package:fitrack/views/sign_up_page.dart';
import 'package:fitrack/views/signing_page.dart';
import 'package:fitrack/views/user_data_page.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BottomNavBloc(),
      child: MainView(),
    );
  }
}

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Dashboard(),
          Signing(),
          UserData(),
          SignUp(),
        ],
        onPageChanged: (index) {
          BlocProvider.of<BottomNavBloc>(context)
              .add(BottomNavEvent.values[index]);
        },
      ),
      bottomNavigationBar: BottomNavView(pageController: _pageController),
    );
  }
}

class BottomNavView extends StatelessWidget {
  final PageController pageController;

  const BottomNavView({Key? key, required this.pageController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavBloc, int>(
      builder: (context, selectedIndex) {
        return SlidingClippedNavBar(
          backgroundColor: FitColors.background,
          onButtonPressed: (index) {
            BlocProvider.of<BottomNavBloc>(context)
                .add(BottomNavEvent.values[index]);
            pageController.animateToPage(index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut);
          },
          iconSize: 35,
          activeColor: FitColors.primary30,
          selectedIndex: selectedIndex,
          barItems: [
            BarItem(
              icon: Icons.home_filled,
              title: 'Home',
            ),
            BarItem(
              icon: Icons.area_chart,
              title: 'Chart',
            ),
            BarItem(
              icon: Icons.app_registration_rounded,
              title: 'Challenge',
            ),
            BarItem(
              icon: Icons.settings,
              title: 'Settings',
            ),
          ],
        );
      },
    );
  }
}
