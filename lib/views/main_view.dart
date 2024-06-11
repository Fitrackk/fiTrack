import 'package:fitrack/configures/bottom_nav_bloc.dart';
import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/views/challenges_page.dart';
import 'package:fitrack/views/dashboard_page.dart';
import 'package:fitrack/views/report_page.dart';
import 'package:fitrack/views/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Main extends StatelessWidget {
  const Main({super.key});

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
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _onPopInvoked(bool isPopInvoked) async {
    if (isPopInvoked) {
      if (_currentIndex != 0) {
        setState(() {
          _currentIndex = 0;
        });
        _pageController.jumpToPage(0);
        BlocProvider.of<BottomNavBloc>(context).add(BottomNavEvent.home);
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: _onPopInvoked,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            Dashboard(),
            ActivityDataPage(),
            Challenges(),
            SettingsPage(),
          ],
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
            BlocProvider.of<BottomNavBloc>(context)
                .add(BottomNavEvent.values[index]);
          },
        ),
        bottomNavigationBar: BottomNavView(
          pageController: _pageController,
          currentIndex: _currentIndex,
          onItemTapped: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class BottomNavView extends StatefulWidget {
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavView({
    super.key,
    required this.pageController,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  _BottomNavViewState createState() => _BottomNavViewState();
}

class _BottomNavViewState extends State<BottomNavView> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      selectedItemColor: FitColors.primary20,
      unselectedItemColor: FitColors.primary30,
      onTap: (index) {
        widget.onItemTapped(index);
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
