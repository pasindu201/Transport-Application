import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:users/user_screens/login_screen.dart';
import '../user_global/global.dart';
import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameTextEditingController.dispose();
    emailTextEditingController.dispose();
    phoneTextEditingController.dispose();
    passwordTextEditingController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await firebaseAuth.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).then((auth) async {
          currentUser = auth.user;
          if (currentUser != null) {
            Map<String, String> userMap = {
              "id": currentUser!.uid,
              "name": nameTextEditingController.text.trim(),
              "email": emailTextEditingController.text.trim(),
              "phone": phoneTextEditingController.text.trim(),
            };
            DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
            userRef.child(currentUser!.uid).set(userMap);

            // Send email verification
            await currentUser!.sendEmailVerification();

            Fluttertoast.showToast(msg: "Successfully Registered. Please check your email to verify your account.");

            // Optional: Navigate to a screen that instructs the user to verify their email
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => EmailVerificationScreen()));
          }
        });
      } catch (error) {
        Fluttertoast.showToast(msg: "Error occurred: \n $error");
      }
    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }


  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(darkTheme ? "images/city_dark.jpg" : "images/city.jpg"),
                SizedBox(height: 20,),
                Text(
                  "Register",
                  style: TextStyle(
                    color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameTextEditingController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                            hintText: "Name",
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.amber.shade400 : Colors.grey),
                          ),
                        ),
                        SizedBox(height: 10,),
                        TextFormField(
                          controller: emailTextEditingController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                            hintText: "e-mail",
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            prefixIcon: Icon(Icons.email, color: darkTheme ? Colors.amber.shade400 : Colors.grey),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return "Please enter an email";
                            }
                            if (!EmailValidator.validate(text)) {
                              return "Please enter a valid email";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10,),
                        TextFormField(
                          controller: phoneTextEditingController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                            hintText: "Phone",
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            prefixIcon: Icon(Icons.phone, color: darkTheme ? Colors.amber.shade400 : Colors.grey),
                          ),
                        ),
                        SizedBox(height: 10,),
                        TextFormField(
                          controller: passwordTextEditingController,
                          obscureText: !_passwordVisible,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            prefixIcon: Icon(Icons.password, color: darkTheme ? Colors.amber.shade400 : Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return "Please enter a password";
                            }
                            if (text.length < 6) {
                              return "Password must be at least 6 characters long";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10,),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkTheme ? Colors.grey : Colors.blue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          onPressed: _submit,
                          child: Text("Register", style: TextStyle(fontSize: 20)),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Have an account?",
                              style: TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                            SizedBox(width: 5,),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginScreen()),
                                );
                              },
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
