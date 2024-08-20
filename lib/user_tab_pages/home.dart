import 'package:flutter/material.dart';
import '../user_global/global.dart';
import '../user_screens/main_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool transportSelected = false;
  bool generalSelected = false;
  bool carPartsSelected = false;
  bool foodItemsSelected = false;
  bool furnitureSelected = false;
  bool constructionSelected = false;

  String selectedCategory = 'General'; 

  void _selectCategory(String category) {
    setState(() {
      transportSelected = category == 'Transport';
      generalSelected = category == 'General';
      carPartsSelected = category == 'Car Parts';
      foodItemsSelected = category == 'Food Items';
      furnitureSelected = category == 'Furniture';
      constructionSelected = category == 'Construction';
    });
  }

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
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 45,
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
                        fontSize: 21,
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
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CategoryCard(
                      imagePath: 'images/truck.png', 
                      label: 'Transport',
                      selected: transportSelected,
                      onTap: () => _selectCategory('Transport'),
                    ),
                    CategoryCard(
                      imagePath: 'images/general.png', 
                      label: 'General',
                      selected: generalSelected,
                      onTap: () => _selectCategory('General'),
                    ),
                    CategoryCard(
                      imagePath: 'images/car_parts.png', 
                      label: 'Car Parts',
                      selected: carPartsSelected,
                      onTap: () => _selectCategory('Car Parts'),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CategoryCard(
                      imagePath: 'images/foods.jpg', 
                      label: 'Food Items',
                      selected: foodItemsSelected,
                      onTap: () => _selectCategory('Food Items'),
                    ),
                    CategoryCard(
                      imagePath: 'images/images.jpg', 
                      label: 'Furniture',
                      selected: furnitureSelected,
                      onTap: () => _selectCategory('Furniture'),
                    ),
                    CategoryCard(
                      imagePath: 'images/construction.jpg', 
                      label: 'Construction',
                      selected: constructionSelected,
                      onTap: () => _selectCategory('Construction'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 6),

          Text("Where to your delivery?"),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              onPressed: () {
                Fluttertoast.showToast(msg: "${selectedCategory}");
                Navigator.push(context, MaterialPageRoute(builder: (c) => UserMainScreen(category: selectedCategory)));
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
            padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
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
  final bool selected;
  final VoidCallback onTap;

  const CategoryCard({
    required this.imagePath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        color: selected ? Colors.blueAccent : Color.fromRGBO(224, 224, 224, 1),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(imagePath, height: 90, width: 90),
                ),
              ),
              SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
