import 'dart:async';
import 'package:flutter/material.dart';
import '../selection_screen.dart';
import '../user_assistants/assistant_methods.dart';
import '../user_global/global.dart';
import '../user_screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  String description_1 =
    "Delivering goods, saving the planet.\nExperience a smarter way to deliver. \nOur app connects you with fast, reliable transport options for all your needs.";

  void startTimer() {
    Timer(const Duration(seconds: 3), () async {
      if (firebaseAuth.currentUser != null) {
        await AssistantMethods.readCurrentOnlineUserInfo();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MainScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const UserSelection()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('Eco-friendly ',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 24)),
                  const SizedBox(height: 15),
                  Image.asset(
                      "images/Ellipse 11.png"), // Replace with your asset image path
                  const SizedBox(height: 24),

                  const Text('Shipping',
                      style: TextStyle(color: Colors.white, fontSize: 48)),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      description_1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
