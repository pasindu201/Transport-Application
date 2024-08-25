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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() async {
    DatabaseReference notificationsRef = FirebaseDatabase.instance.ref().child("All Ride Requests");

    try {
      DatabaseEvent event = await notificationsRef.once();
      Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          notifications.clear();
          data.forEach((key, value) {
            notifications.add({
              "id": key,
              "userName": value['userName'] ?? 'Unknown',
              "originAddress": value['originAddress'] ?? 'Unknown',
              "destinationAddress": value['destinationAddress'] ?? 'Unknown',
              "time": value['time'] ?? DateTime.now().toIso8601String(),
              "serviceType": value['serviceType'] ?? 'N/A',
              "capacity": value['capacity'] ?? 'N/A',
              "weight": value['weight'] ?? 'N/A',
              "instructions": value['instructions'] ?? 'No instructions provided',
            });
          });
        });
      }
    } catch (error) {
      print("Error fetching notifications: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load notifications")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
              Text("Time: ${_formatTime(notification['time'])}"),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(child: Text("No notifications available"))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    var notification = notifications[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: Icon(Icons.notifications, color: Colors.blue),
                        title: Text(notification['originAddress']),
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
