import 'package:flutter/material.dart';

import 'driver_screens/register_screen.dart';
import 'user_screens/register_screen.dart';

class UserSelection extends StatelessWidget {
  const UserSelection({super.key});

  @override
  Widget build(BuildContext context) {

    String description_1 = "Delivering goods, saving the planet.\nExperience a smarter way to deliver. \nOur app connects you with fast, reliable transport options for all your needs.";

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Eco-friendly ',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 15),
                  Image.asset(
                    "images/Ellipse 11.png", 
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Shipping',
                    style: TextStyle(color: Colors.white, fontSize: 48),
                  ),
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
            const Text(
              'What type of user you are! ',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DriverRegisterScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(135, 50),
                    ),
                    child: const Text(
                      'Driver',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  SizedBox(width: 2),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const RegisterScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(135, 50),
                    ),
                    child: const Text(
                      'Customer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
