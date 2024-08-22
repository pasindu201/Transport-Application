import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RatingPage extends StatefulWidget {
  final String? pickUpAddress;
  final String? destinationAddress;
  final String driverId;

  RatingPage({
    required this.driverId,
    required this.pickUpAddress,
    required this.destinationAddress,
  });

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _rating = 0.0;

  void _submitRating() {
    // Ensure pickUpAddress and destinationAddress are not null
    String pickUp = widget.pickUpAddress ?? "NA";
    String destination = widget.destinationAddress ?? "NA";

    DatabaseReference ratingRef = FirebaseDatabase.instance
        .ref()
        .child("driver_ratings")
        .child(widget.driverId);

    ratingRef.set({
      "rating": _rating,
      "pickUp": pickUp,
      "destination": destination,
    }).then((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Rating submitted!")));
    }).catchError((error) {
      print("Error submitting rating: $error");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to submit rating")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Driver'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Rate the driver:',
            style: TextStyle(fontSize: 24),
          ),
          Slider(
            value: _rating,
            onChanged: (newRating) {
              setState(() {
                _rating = newRating;
              });
            },
            min: 0,
            max: 5,
            divisions: 5,
            label: '$_rating',
          ),
          ElevatedButton(
            child: Text('Submit'),
            onPressed: _submitRating,
          ),
        ],
      ),
    );
  }
}
