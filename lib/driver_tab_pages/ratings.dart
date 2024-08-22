import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../driver_global/global.dart';

class RatingsPage extends StatefulWidget {
  const RatingsPage({super.key});

  @override
  State<RatingsPage> createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  double _selectedRating = 0.0;

  void _submitRating() {
    DatabaseReference ratingRef = FirebaseDatabase.instance
        .ref()
        .child("driver_ratings")
        .child(onlineDriverData.id!);

    ratingRef.set({
      "rating": _selectedRating,
      "pickUp": 'Sample pickup address', // Replace with actual pickup address
      "destination": 'Sample destination address' // Replace with actual destination address
    }).then((_) {
      Navigator.pop(context);
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
              'Tuesday, 23 Mar, 14:10',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 4),
            Text(
              'Order F-1169872841',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // Status section
            Text(
              'Food delivered',
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
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                'Rp1.000', 'Rp2.500', 'Rp5.000', 'Rp10.000', 'Rp15.000', 'Rp20.000',
                'Rp30.000', 'Rp50.000', 'Rp80.000', 'Rp100.000'
              ].map((tip) {
                return OutlinedButton(
                  child: Text(tip),
                  onPressed: () {
                    // Implement your tip handling logic here
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Submit button
            Center(
              child: ElevatedButton(
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
