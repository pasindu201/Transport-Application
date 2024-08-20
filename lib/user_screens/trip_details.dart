import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TripDetails extends StatefulWidget {
  final String? category;

  TripDetails({required this.category});

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  final TextEditingController specialInstructionsTextEditingController = TextEditingController();

  // Variables for storing selected dropdown values
  late String selectedServiceType = widget.category ?? "Transport";
  String? selectedVehicleType;
  String? selectedWeight;
  String? instructions;

  // Sample data for dropdowns
  final List<String> serviceTypes = ["Transport", "General", "Car Parts", "Food Items", "Furniture", "Construction"];
  final List<String> vehicleTypes = ["Car", "Motorbike", "Lorry", "Truck", "Van"];
  final List<String> weights = ["< 1 kg", "1-5 kg", "5-10 kg", "10-20 kg", "> 20 kg"];

  // Function to handle form submission
  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Process the form submission
      print("Form Submitted");
      // You can also add any other processing or navigation logic here
    }
  }

  // GlobalKey to manage form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Trip Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 5,
        centerTitle: true,
        backgroundColor: darkTheme ? Colors.black : Colors.blue,
        iconTheme: IconThemeData(
          color: darkTheme ? Colors.amber.shade400 : Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: "Service Type",
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
                value: selectedServiceType,
                items: serviceTypes.map((service) {
                  return DropdownMenuItem(
                    child: Text(service, style: TextStyle(color: Colors.grey)),
                    value: service,
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedServiceType = newValue!;
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
                  hintText: "Vehicle Type",
                  prefixIcon: Icon(Icons.directions_car, color: darkTheme ? Colors.amber.shade400 : Colors.grey),
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
                items: vehicleTypes.map((vehicle) {
                  return DropdownMenuItem(
                    child: Text(vehicle, style: TextStyle(color: Colors.grey)),
                    value: vehicle,
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedVehicleType = newValue;
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
                  hintText: "Weight",
                  prefixIcon: Icon(Icons.scale, color: darkTheme ? Colors.amber.shade400 : Colors.grey),
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
                items: weights.map((weight) {
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
                    return 'Please select a weight';
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),

              TextFormField(
                controller: specialInstructionsTextEditingController,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(100)
                ],
                decoration: InputDecoration(
                  hintText: "Special Instructions",
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter any special instructions';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

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
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    specialInstructionsTextEditingController.dispose();
    super.dispose();
  }
}
