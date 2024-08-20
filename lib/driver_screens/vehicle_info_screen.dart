import '../splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import '../driver_global/global.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key});

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  final TextEditingController carNumberTextEditingController = TextEditingController();
  final TextEditingController serviceTextEditingController = TextEditingController();
  final TextEditingController vehicleTextEditingController = TextEditingController();

  List<String> serviceTypes = ["Transport", "General", "Car Parts", "Food Items", "Furniture", "Construction"];
  String? selectedServiceType;

  List<String> carTypes = ["Car", "Motorbike", "Lorry", "Truck"];
  String? selectedCarType;

  List<String> weightOptions = ["< 1 kg", "1-5 kg", "5-10 kg", "10-20 kg", "> 20 kg"];
  String? selectedWeight;

  final _formKey = GlobalKey<FormState>();

  _submit() {
    if (_formKey.currentState!.validate()) {
      Map<String, String> driverCarInfoMap = {
        "number": carNumberTextEditingController.text.trim(),
        "capacity": selectedWeight ?? "",
        "service": selectedServiceType ?? "",
        "type": selectedCarType ?? "",
      };

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");
      userRef.child(currentUser!.uid).child("vehicle_details").set(driverCarInfoMap);

      Fluttertoast.showToast(msg: "Car details have been saved.");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => SplashScreen()),
      );
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
        appBar: AppBar(
          title: Text(
            "Vehicle Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          elevation: 5,
          centerTitle: true,
          backgroundColor: darkTheme ? Colors.black : Colors.blue,
        ),
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(darkTheme ? "images/delivery.jpeg" : "images/delivery.jpeg"),

                SizedBox(height: 15),

                Text(
                  "Add Vehicle details",
                  style: TextStyle(
                    color: darkTheme ? Colors.amber.shade400 : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: carNumberTextEditingController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                            hintText: "Vehicle Number",
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
                            prefixIcon: Icon(Icons.directions_car, color: darkTheme ? Colors.amber.shade400 : Colors.grey),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter vehicle number';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: "Your Service Type",
                            prefixIcon: Icon(Icons.build, color: darkTheme ? Colors.amber.shade400 : Colors.grey),
                            filled: true,
                            fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                          ),
                          items: serviceTypes.map((service) {
                            return DropdownMenuItem(
                              child: Text(service, style: TextStyle(color: Colors.grey)),
                              value: service,
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedServiceType = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a service type';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: "Please Choose Vehicle Type",
                            prefixIcon: Icon(Icons.local_taxi, color: darkTheme ? Colors.amber.shade400 : Colors.grey),
                            filled: true,
                            fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                          ),
                          items: carTypes.map((car) {
                            return DropdownMenuItem(
                              child: Text(car, style: TextStyle(color: Colors.grey)),
                              value: car,
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedCarType = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a vehicle type';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: "Vehicle Weight",
                            prefixIcon: Icon(Icons.line_weight, color: darkTheme ? Colors.amber.shade400 : Colors.grey),
                            filled: true,
                            fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                          ),
                          items: weightOptions.map((weight) {
                            return DropdownMenuItem(
                              child: Text(weight, style: TextStyle(color: Colors.grey)),
                              value: weight,
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedWeight = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a vehicle weight';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 10),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkTheme ? Colors.grey : Colors.blue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          onPressed: _submit,
                          child: Text("Confirm", style: TextStyle(fontSize: 20, color: Colors.white)),
                        ),

                        SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Have an account?",
                              style: TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                            SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
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
