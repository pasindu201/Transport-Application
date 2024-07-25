import 'package:flutter/material.dart';

class PayFareAmountDialog extends StatefulWidget {
  
  double? fareAmount;

  PayFareAmountDialog({this.fareAmount});

  @override
  State<PayFareAmountDialog> createState() => _PayFareAmountDialogState();
}

class _PayFareAmountDialogState extends State<PayFareAmountDialog> {
  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: darkTheme ? Colors.black : Colors.blue,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Text("Fare amount".toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: darkTheme ? Colors.amber.shade400 : Colors.white,
              fontSize: 16,
            ),),

            SizedBox(height: 20,),

            Divider(
              thickness: 2,
              color: darkTheme ? Colors.amber.shade400 : Colors.white,
            ),

            SizedBox(height: 20,),

            Text("${widget.fareAmount} LKR", style: TextStyle(
              fontWeight: FontWeight.bold,
              color: darkTheme ? Colors.amber.shade400 : Colors.white,
              fontSize: 36,
            ),),

            SizedBox(height: 15,),

            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "This is the total trip fare amount. Please pay the fare amount to the driver.",
                 style: TextStyle(
                   color: darkTheme ? Colors.amber.shade400 : Colors.white,
                   fontSize: 14,
                 ),
              ),
              ),

            SizedBox(height: 20,),

            Padding(padding: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close", style: TextStyle(
                color: darkTheme ? Colors.black : Colors.white,
              ),),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(darkTheme ? Colors.amber.shade400 : Colors.blue),
              ),
            ),
            )  
          ],
        ),
      ),
    );
  }
}