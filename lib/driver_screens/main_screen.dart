import 'package:flutter/material.dart';
import '../driver_global/global.dart';
import '../driver_tab_pages/home.dart';
import '../driver_tab_pages/profile.dart';
import '../driver_tab_pages/ratings.dart'; // Add your Earnings page
import '../driver_tab_pages/notifications.dart'; // Add your Notifications page

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({super.key});

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  int _bottomBarIndex = 0;
  bool _isPageTwoLocked = false;
  final int _activateTime = 2000; // Lock duration in milliseconds

  @override
  void initState() {
    super.initState();
    isDriverAvailable = true;
  }

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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: IndexedStack(
        index: _bottomBarIndex,
        children: [
          HomeTabPage(key: PageStorageKey('home')),
          DriverRatingsPage(key: PageStorageKey('ratings')), // Your Earnings page
          NotificationsTabPage(key: PageStorageKey('notifications')), // Your Notifications page
          DriverProfilePage(key: PageStorageKey('profile')),
        ],
      ),
      bottomNavigationBar: AbsorbPointer(
        absorbing: _isPageTwoLocked,
        child: BottomNavigationBar(
          backgroundColor: Colors.grey, 
          selectedItemColor: Colors.blue, 
          unselectedItemColor: Colors.black,
          unselectedFontSize: 5,
          currentIndex: _bottomBarIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: 'Ratings', 
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications', 
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
