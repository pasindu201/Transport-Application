import 'car_info_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Your Email'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'A verification email has been sent to your email address. Please check your inbox and click on the verification link.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null && !user.emailVerified) {
                  await user.sendEmailVerification();
                  Fluttertoast.showToast(
                      msg:
                          "Verification email resent. Please check your email.");
                }
              },
              child: Text('Resend Verification Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                await user?.reload();
                user = FirebaseAuth.instance.currentUser;
                if (user != null && user.emailVerified) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (c) => CarInfoScreen()));
                } else {
                  Fluttertoast.showToast(
                      msg: "Please verify your email first.");
                }
              },
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
