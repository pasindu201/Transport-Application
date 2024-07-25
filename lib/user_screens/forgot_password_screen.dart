import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:users/user_global/global.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'register_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailTextEditingController = TextEditingController();
  
  void _submit() {
    firebaseAuth.sendPasswordResetEmail(email: emailTextEditingController.text.trim()
    ).then((value) {
      Fluttertoast.showToast(msg:"We have sent you as email to recover password, please check email");
    }).onError((error, stackTrace){
      Fluttertoast.showToast(msg: "Error Occured: \n ${error.toString()}");
    });
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
                  "Forgot password",
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

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkTheme ? Colors.grey : Colors.blue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          onPressed: _submit,
                          child: Text("Send reset password link", style: TextStyle(fontSize: 20)),
                        ),
                        SizedBox(height: 10,),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                            SizedBox(width: 5,),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => RegisterScreen()));
                              },
                              child: Text(
                                "Register",
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
