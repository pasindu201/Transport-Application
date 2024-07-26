import 'package:flutter/material.dart';
import '../user_global/global.dart';
import '../user_screens/main_screen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('images/profileicon.jpg'), 
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning ...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Your Delivery Starts here',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CategoryCard(
                      imagePath: 'images/truck.png', 
                      label: 'Transport',
                    ),
                    CategoryCard(
                      imagePath: 'images/general.png', 
                      label: 'General',
                    ),
                    CategoryCard(
                      imagePath: 'images/car_parts.png', 
                      label: 'Car Parts',
                    ),
                  ],
          ),

          SizedBox(height: 10,),

          const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CategoryCard(
                    imagePath: 'images/foods.jpg', 
                    label: 'Food Items',
                  ),
                  CategoryCard(
                    imagePath: 'images/images.jpg', 
                    label: 'Furniture',
                  ),
                  CategoryCard(
                    imagePath: 'images/construction.jpg', 
                    label: 'Construction',
                  ),
                ],
          ),
              ],
            ),
          ),

          SizedBox(height: 6,),    

          Text("Where to your delivery"),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const UserMainScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Take A Trip',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),

         Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,  // Set the color of the border
                  width: 2.0,           // Set the width of the border
                ),
                borderRadius: BorderRadius.circular(10.0),  // Set the border radius for rounded corners
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),  // Same border radius for the image clip
                child: Image.asset("images/flyer.jpg"),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String imagePath;
  final String label;

  const CategoryCard({required this.imagePath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      color: Color.fromRGBO(224, 224, 224, 1),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), // Frame border radius
                border: Border.all(color: Colors.grey, width: 2), // Frame border
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), // Image border radius
                child: Image.asset(imagePath, height: 90, width: 90),
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}