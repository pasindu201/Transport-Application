import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../user_global/global.dart';

class ActivityTabPage extends StatefulWidget {
  const ActivityTabPage({super.key});

  @override
  State<ActivityTabPage> createState() => _ActivityTabPageState();
}

class _ActivityTabPageState extends State<ActivityTabPage> {
  List<Map<dynamic, dynamic>> rideRequests = [];

  @override
  void initState() {
    super.initState();
    fetchRideRequests();
  }

  void fetchRideRequests() async {
    DatabaseReference rideRequestsRef = FirebaseDatabase.instance.ref().child("All Ride Requests");

    // Listening for changes in ride requests
    rideRequestsRef.onValue.listen((event) {
      Map<dynamic, dynamic> allRequests = event.snapshot.value as Map<dynamic, dynamic>;
      List<Map<dynamic, dynamic>> filteredRequests = [];

      allRequests.forEach((key, value) {
        if (value['userName'] == userModelCurrentinfo!.name) {
          filteredRequests.add(value);
        }
      });

      setState(() {
        rideRequests = filteredRequests;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Activity'),
      ),
      body: rideRequests.isEmpty
          ? const Center(child: Text('No ride activity found.'))
          : ListView.builder(
              itemCount: rideRequests.length,
              itemBuilder: (context, index) {
                var request = rideRequests[index];
                return ListTile(
                  title: Text('${request['originAddress']} to ${request['destinationAddress']}'),
                  subtitle: Text('Time: ${request['time']}'),
                  trailing: Text('${request['serviceType']}'),
                  onTap: () {
                    // You can handle tapping on an item here if needed
                  },
                );
              },
            ),
    );
  }
}
