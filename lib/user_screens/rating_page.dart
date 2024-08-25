import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../driver_global/global.dart';
import 'home_screen.dart';

class RatingsPage extends StatefulWidget {
  final String driverId;
  final String? pickUpAddress;
  final String? destinationAddress;

  RatingsPage({
    Key? key,
    required this.driverId,
    this.pickUpAddress,
    this.destinationAddress,
  }) : super(key: key);

  @override
  State<RatingsPage> createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  double _selectedRating = 0.0;

  void _submitRating() {
    DatabaseReference ratingRef = FirebaseDatabase.instance
        .ref()
        .child("driver_ratings")
        .child(widget.driverId);

    ratingRef.set({
      "rating": _selectedRating,
      "pickUp": widget.pickUpAddress ?? 'Unknown pickup address', 
      "destination": widget.destinationAddress ?? 'Unknown destination address',
    }).then((_) {
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => UserHomePage()));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Rating submitted!")));
    }).catchError((error) {
      print("Error submitting rating: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit rating")));
    });
  }

  Widget _buildStar(int index) {
    return IconButton(
      icon: Icon(
        Icons.star,
        color: index <= _selectedRating ? Colors.amber : Colors.grey,
        size: 40,
      ),
      onPressed: () {
        setState(() {
          _selectedRating = index.toDouble();
        });
      },
    );
  }

  Widget _buildTipButton(String amount) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(90, 40), // Adjust the size as needed
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        amount,
        style: TextStyle(fontSize: 14), // Adjust font size if needed
      ),
      onPressed: () {
        // Implement your tip handling logic here
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Driver'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header section
            Text(
              "Pick Up: ${widget.pickUpAddress ?? 'Unknown'}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Destination: ${widget.destinationAddress ?? 'Unknown'}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Status section
            Text(
              'Successfully Delivered',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Rating stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => _buildStar(index + 1)),
            ),
            SizedBox(height: 20),

            // Tip section
            Text(
              'Do you want to tip the driver?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Divider(),

            // Tip buttons arranged in a Row with Columns
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    _buildTipButton('Rp1.000'),
                    SizedBox(height: 10),
                    _buildTipButton('Rp10.000'),
                    SizedBox(height: 10),
                    _buildTipButton('Rp30.000'),
                  ],
                ),
                Column(
                  children: [
                    _buildTipButton('Rp2.500'),
                    SizedBox(height: 10),
                    _buildTipButton('Rp15.000'),
                    SizedBox(height: 10),
                    _buildTipButton('Rp50.000'),
                  ],
                ),
                Column(
                  children: [
                    _buildTipButton('Rp5.000'),
                    SizedBox(height: 10),
                    _buildTipButton('Rp20.000'),
                    SizedBox(height: 10),
                    _buildTipButton('Rp80.000'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // Submit button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(150, 50), // Size of the submit button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Submit'),
                onPressed: _submitRating,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
