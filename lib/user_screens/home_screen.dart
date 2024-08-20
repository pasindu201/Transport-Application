import 'package:flutter/material.dart';
import '../user_tab_pages/account.dart';
import '../user_tab_pages/home.dart';
import '../user_tab_pages/activity.dart';
import '../user_tab_pages/notifications.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _bottomBarIndex = 0;
  bool _isPageTwoLocked = false;
  final int _activateTime = 2000; // Lock duration in milliseconds

  void _onItemTapped(int index) {
    if (_isPageTwoLocked && index == 1) {
      // Prevent switching to Page2 if it's locked
      return;
    }

    setState(() {
      _bottomBarIndex = index;
      if (index == 1) {
        _isPageTwoLocked = true;
        // Unlock after the specified duration
        Future.delayed(Duration(milliseconds: _activateTime), () {
          setState(() {
            _isPageTwoLocked = false;
          });
        });
      }
    });
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    bool isLocked = index == 1 && _isPageTwoLocked;
    return GestureDetector(
      onTap: () {
        if (!isLocked) _onItemTapped(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isLocked
                ? Colors.grey
                : (_bottomBarIndex == index ? Colors.black : const Color.fromARGB(255, 90, 90, 90)),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isLocked
                  ? Colors.grey
                  : (_bottomBarIndex == index ? Colors.black : const Color.fromARGB(255, 90, 90, 90)),
            ),
          ),
        ],
      ),
    );
  }

  Widget customBottomNavigationBar() {
    return Container(
      color: const Color.fromARGB(255, 211, 211, 211),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 6.0, 0, 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 0, 'Home'),
            _buildNavItem(Icons.credit_card, 1, 'Activity'),
            _buildNavItem(Icons.notifications, 2, 'Notifications'),
            _buildNavItem(Icons.person, 3, 'Account'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _bottomBarIndex,
        children: const [
          Home(key: PageStorageKey('home')),
          ActivityTabPage(key: PageStorageKey('activity')), // Your Activity page
          NotificationsTabPage(key: PageStorageKey('notifications')), // Your Notifications page
          UserProfilePage(key: PageStorageKey('profile')), // Your Account page
        ],
      ),
      bottomNavigationBar: AbsorbPointer(
        absorbing: _isPageTwoLocked,
        child: customBottomNavigationBar(),
      ),
    );
  }
}
