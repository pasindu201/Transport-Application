import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../selection_screen.dart';
import '../user_global/global.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController nameTextEditingController = TextEditingController();
  final TextEditingController phoneTextEditingController = TextEditingController();
  final TextEditingController emailTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> readCurrentUserInfo() async {
    try {
      currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception("No current user found");
      }

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);
      final snapshot = await userRef.once();

      if (snapshot.snapshot.value != null) {
        var userData = snapshot.snapshot.value as Map;
        onlineUserData.id = userData["id"];
        onlineUserData.name = userData["name"];
        onlineUserData.phone = userData["phone"];
        onlineUserData.email = userData["email"];

        // Populate the text editing controllers
        if (mounted) {
          setState(() {
            nameTextEditingController.text = onlineUserData.name ?? '';
            phoneTextEditingController.text = onlineUserData.phone ?? '';
            emailTextEditingController.text = onlineUserData.email ?? '';
          });
        }
      } else {
        throw Exception("User data not found");
      }
    } catch (e) {
      print("Error reading user info: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load user info: $e")));
    }
  }

  Future<void> updateUserProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      Map<String, dynamic> userData = {
        "name": nameTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);

      await userRef.update(userData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully.")));
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update profile: $e")));
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await firebaseAuth.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => UserSelection()));
    } catch (e) {
      print("Error logging out: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to log out: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    readCurrentUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Profile",
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
                  title: const Text("Your Name", style: TextStyle(fontWeight: FontWeight.bold)),
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
                const Divider(color: Colors.grey, thickness: 1),

                // Email Address
                ListTile(
                  leading: Icon(Icons.email, color: darkTheme ? Colors.white : Colors.blue),
                  title: const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(emailTextEditingController.text.isNotEmpty ? emailTextEditingController.text : "Email not found"),
                ),
                const Divider(color: Colors.grey, thickness: 1),

                // Mobile Number
                ListTile(
                  leading: Icon(Icons.phone, color: darkTheme ? Colors.white : Colors.blue),
                  title: const Text("Mobile Number", style: TextStyle(fontWeight: FontWeight.bold)),
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
                const Divider(color: Colors.grey, thickness: 1),

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
                        onPressed: updateUserProfile,
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
                        onPressed: () => logout(context),
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
