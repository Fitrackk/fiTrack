import 'package:fitrack/configures/BottomNavBloc.dart';
import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/views/challenges.dart';
import 'package:fitrack/views/dashboard_page.dart';
import 'package:fitrack/views/report_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../views/setting_page.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BottomNavBloc(),
      child: const MainView(),
    );
  }
}

class MainView extends StatefulWidget {
  const MainView({super.key});

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
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Dashboard(),
          ActivityDataPage(),
          Challenges(),
          Setting(),
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

class BottomNavView extends StatefulWidget {
  final PageController pageController;

  const BottomNavView({super.key, required this.pageController});

  @override
  _BottomNavViewState createState() => _BottomNavViewState();
}

class _BottomNavViewState extends State<BottomNavView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: FitColors.background,
      currentIndex: _selectedIndex,
      selectedItemColor: FitColors.primary20,
      unselectedItemColor: FitColors.primary30,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        BlocProvider.of<BottomNavBloc>(context)
            .add(BottomNavEvent.values[index]);
        widget.pageController.animateToPage(index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      },
      items: const [
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/images/home.png'),
            size: 35,
          ),
          label: '・',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/images/chart.png'),
            size: 35,
          ),
          label: '・',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/images/challenge.png'),
            size: 35,
          ),
          label: '・',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/images/setting.png'),
            size: 35,
          ),
          label: '・',
        ),
      ],
      selectedIconTheme:
          const IconThemeData(color: FitColors.primary20, size: 30),
      unselectedIconTheme:
          const IconThemeData(color: FitColors.primary30, size: 30),
      selectedLabelStyle:
          const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }
}
