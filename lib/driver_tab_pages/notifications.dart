import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class NotificationsTabPage extends StatefulWidget {
  const NotificationsTabPage({super.key});

  @override
  State<NotificationsTabPage> createState() => _NotificationsTabPageState();
}

class _NotificationsTabPageState extends State<NotificationsTabPage> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() {
    DatabaseReference notificationsRef = FirebaseDatabase.instance.ref().child("All Ride Requests");
    
    notificationsRef.once().then((DatabaseEvent event) {
      Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        data.forEach((key, value) {
          setState(() {
            notifications.add({
              "id": key,
              "userName": value['userName'],
              "originAddress": value['originAddress'],
              "destinationAddress": value['destinationAddress'],
              "time": value['time'],
              "serviceType": value['serviceType'],
              "capacity": value['capacity'],
              "weight": value['weight'],
              "instructions": value['instructions'],
            });
          });
        });
      }
    });
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ride Request Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("User Name: ${notification['userName']}"),
              Text("Origin: ${notification['originAddress']}"),
              Text("Destination: ${notification['destinationAddress']}"),
              Text("Time: ${notification['time']}"),
              Text("Service Type: ${notification['serviceType']}"),
              Text("Capacity: ${notification['capacity']}"),
              Text("Weight: ${notification['weight']}"),
              Text("Instructions: ${notification['instructions']}"),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(String timeString) {
    DateTime dateTime = DateTime.parse(timeString);
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.blue,
      ),
      body: notifications.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                var notification = notifications[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Icon(Icons.notifications, color: Colors.blue),
                    title: Text(notification['originAddress'] ?? 'Unknown'),
                    subtitle: Text(_formatTime(notification['time'])),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => _showNotificationDetails(notification),
                  ),
                );
              },
            ),
    );
  }
}
