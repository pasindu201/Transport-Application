import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../driver_global/global.dart';
import '../selection_screen.dart';

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({Key? key}) : super(key: key);
  @override
  _DriverProfilePageState createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  final TextEditingController nameTextEditingController = TextEditingController();
  final TextEditingController phoneTextEditingController = TextEditingController();
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController vehicleNumberTextEditingController = TextEditingController();

  String? selectedServiceType;
  String? selectedVehicleType;
  String? selectedWeightRange;

  final List<String> serviceTypes = ["Transport", "General", "Car Parts", "Food Items", "Furniture", "Construction"];
  final List<String> vehicleTypes = ["Car", "Motorbike", "Lorry", "Truck"];
  final List<String> weightRanges = ["< 1 kg", "1-5 kg", "5-10 kg", "10-20 kg", "> 20 kg"];

  String email = "driver@example.com";

  final _formKey = GlobalKey<FormState>();

  Future<void> logout(BuildContext context) async {
    // Sign out from Firebase
    await firebaseAuth.signOut();

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => UserSelection()));
  }

  Future<void> readCurrentDriverInformation() async {
    currentUser = firebaseAuth.currentUser;
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        var driverData = snap.snapshot.value as Map;
        onlineDriverData.id = driverData["id"];
        onlineDriverData.name = driverData["name"];
        onlineDriverData.phone = driverData["phone"];
        onlineDriverData.email = driverData["email"];
        onlineDriverData.vehicle_number = driverData["vehicle_details"]["number"];
        onlineDriverData.service_type = driverData["vehicle_details"]["service"];
        onlineDriverData.vehicle_type = driverData["vehicle_details"]["type"];
        onlineDriverData.weight_capacity = driverData["vehicle_details"]["capacity"];

        // Populate the text editing controllers
        setState(() {
          nameTextEditingController.text = onlineDriverData.name ?? '';
          phoneTextEditingController.text = onlineDriverData.phone ?? '';
          emailTextEditingController.text = onlineDriverData.email ?? '';
          vehicleNumberTextEditingController.text = onlineDriverData.vehicle_number ?? '';
          selectedServiceType = onlineDriverData.service_type;
          selectedVehicleType = onlineDriverData.vehicle_type;
          selectedWeightRange = onlineDriverData.weight_capacity;
        });
      }
    });
  }

Future<void> updateProfile() async {
  Map<String, dynamic> driverData = {
    "name": nameTextEditingController.text.trim(),
    "phone": phoneTextEditingController.text.trim(),
    "vehicle_details": {
      "number": vehicleNumberTextEditingController.text.trim(),
      "service": selectedServiceType,
      "type": selectedVehicleType,
      "capacity": selectedWeightRange,
    },
  };

  DatabaseReference driverRef = FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid);

  await driverRef.update(driverData).then((_) {
    // Show a confirmation message or do something after the update
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully.")));
  });
}

  @override
  void initState() {
    super.initState();
    readCurrentDriverInformation();
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Driver Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 5,
        centerTitle: true,
        backgroundColor: darkTheme ? Colors.black : Colors.blue,
      ),
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Info",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Full Name
                ListTile(
                  leading: Icon(Icons.person, color: darkTheme ? Colors.white : Colors.blue),
                  title: const Text("Your Name", style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text(nameTextEditingController.text.isNotEmpty ? nameTextEditingController.text : "Enter your name"),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    String? updatedName = await _editTextField(context, "Your Name", nameTextEditingController.text);
                    if (updatedName != null) {
                      setState(() {
                        nameTextEditingController.text = updatedName;
                      });
                    }
                  },
                ),
                const Divider(
                  color: Colors.grey, 
                  thickness: 1, 
                ),
                
                // Email Address
                ListTile(
                  leading: Icon(Icons.email, color: darkTheme ? Colors.white : Colors.blue),
                  title: const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text(emailTextEditingController.text.isNotEmpty ? emailTextEditingController.text : "email not found"),
                ),
                const Divider(
                  color: Colors.grey, 
                  thickness: 1, 
                ),
                
                // Mobile Number
                ListTile(
                  leading: Icon(Icons.phone, color: darkTheme ? Colors.white : Colors.blue),
                  title: const Text("Mobile Number", style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text(phoneTextEditingController.text.isNotEmpty ? phoneTextEditingController.text : "Enter your mobile number"),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    String? updatedPhone = await _editTextField(context, "Mobile Number", phoneTextEditingController.text);
                    if (updatedPhone != null) {
                      setState(() {
                        phoneTextEditingController.text = updatedPhone;
                      });
                    }
                  },
                ),
                const Divider(
                  color: Colors.grey, 
                  thickness: 1, 
                ),

                const SizedBox(height: 20),

                const Text(
                  "Vehicle Info",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Vehicle Number
                ListTile(
                  leading: Icon(Icons.directions_car, color: darkTheme ? Colors.white : Colors.blue),
                  title: const Text("Vehicle Number", style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text(vehicleNumberTextEditingController.text.isNotEmpty ? vehicleNumberTextEditingController.text : "Enter your vehicle number"),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    String? updatedVehicleNumber = await _editTextField(context, "Vehicle Number", vehicleNumberTextEditingController.text);
                    if (updatedVehicleNumber != null) {
                      setState(() {
                        vehicleNumberTextEditingController.text = updatedVehicleNumber;
                      });
                    }
                  },
                ),
                const Divider(
                  color: Colors.grey, 
                  thickness: 1, 
                ),

                // Service Type Dropdown
                buildDropdownField(Icons.directions_car, "Service Type", serviceTypes, selectedServiceType, (newValue) {
                  setState(() {
                    selectedServiceType = newValue;
                  });
                }),

                const Divider(
                  color: Colors.grey, 
                  thickness: 1, 
                ),

                // Vehicle Type Dropdown
                buildDropdownField(Icons.directions_car, "Vehicle Type", vehicleTypes, selectedVehicleType, (newValue) {
                  setState(() {
                    selectedVehicleType = newValue;
                  });
                }),

                const Divider(
                  color: Colors.grey, 
                  thickness: 1, 
                ),

                // Weight Range Dropdown
                buildDropdownField(Icons.line_weight, "Weight Range", weightRanges, selectedWeightRange, (newValue) {
                  setState(() {
                    selectedWeightRange = newValue;
                  });
                }),

                const Divider(
                  color: Colors.grey, 
                  thickness: 1, 
                ),

                // Update Profile Button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: SizedBox(
                      width: 300, // Set a fixed width
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkTheme ? Colors.grey : Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            updateProfile();
                          }
                        },
                        child: const Text(
                          "Update Profile",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),

                // Log out Button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: SizedBox(
                      width: 300, // Set a fixed width
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkTheme ? Colors.grey : Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          logout(context);
                        },
                        child: const Text(
                          "Logout",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _editTextField(BuildContext context, String title, String initialValue) {
    TextEditingController controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit $title"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: title,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: const Text('SAVE'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }
}

Widget buildDropdownField(IconData icon, String label, List<String> items, String? selectedItem, Function(String?) onChanged) {
  return ListTile(
    leading: Icon(icon, color: Colors.blue),
    title: DropdownButtonFormField<String>(
      value: selectedItem,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
      ),
    ),
  );
}
