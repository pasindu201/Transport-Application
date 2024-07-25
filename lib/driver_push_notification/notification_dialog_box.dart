import '../driver_assistants/assistant_methods.dart';
import '../driver_global/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../driver_models/user_ride_request_information.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';


class NotificationDialogBox extends StatefulWidget {
  
  UserRideRequestInformation? userRideRequestInformation;
  NotificationDialogBox({this.userRideRequestInformation});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {

     bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              onlineDriverData.car_type == "Car"? "images/car.png" : "images/bike.png",
            ),
            SizedBox(height: 8,),

            Text("New Ride Request",
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: darkTheme ? Colors.white : Colors.black,
                ),            
            ),

            SizedBox(height: 8,),

            Divider(
              height: 2,
              thickness: 2,
              color: darkTheme ? Colors.white : Colors.black,
              ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(children: [
                Row(
                  children: [
                    Image.asset("images/pick.png", height: 16, width: 16,),

                    SizedBox(width: 10,),

                    Expanded(child: Container(
                      child: Text(widget.userRideRequestInformation!.originAddress!,
                      style: TextStyle(
                        fontSize: 18,
                        color: darkTheme ? Colors.white : Colors.black,
                         ),
                        ),                     
                      ),
                    ),

                    SizedBox(width: 10,),

                    Row(children: [
                      Image.asset("images/pick",
                      height: 16,
                      width: 16,),

                      SizedBox(width: 10,),

                      Expanded(child: Container(
                        child: Text(
                          widget.userRideRequestInformation!.destinationAddress!,
                          style: TextStyle(
                            fontSize: 18,
                            color: darkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                        )
                      )
                    ],)

                  ],
                )
              ],),
              ),

              Divider(
                height: 2,
                thickness: 2,
                color: darkTheme ? Colors.white : Colors.black,
              ),
              
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(children: [
                  ElevatedButton(
                    onPressed: (){
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();

                      Navigator.pop(context);
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkTheme ? Colors.white : Colors.black,
                    ),
                    child: Text(
                      "cancel".toUpperCase(),
                      style: TextStyle(fontSize: 15),
                    )
                    ),

                    SizedBox(width: 20,),

                    ElevatedButton(
                      onPressed: (){
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer = AssetsAudioPlayer();

                        acceptRideRequest(context);
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text(
                        "accept".toUpperCase(),
                        style: TextStyle(fontSize: 15),                    
                      ),
                    ),  
                ],),
              )

        ],),
      ),
    );
  }

  acceptRideRequest(BuildContext context){
    FirebaseDatabase.instance.ref()
      .child("drivers")
      .child(firebaseAuth.currentUser!.uid)
      .child("newRideStatus")
      .once()
      .then((snap){
        if(snap.snapshot.value == "idle"){
          FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("newRideStatus").set("accepted");

          AssistantMethods.pauseLiveLocationUpdate();

          // Navigator.push(context, MaterialPageRoute(builder: (c) => NewTripScreen()));
          
        }
        else{
          Fluttertoast.showToast(msg: "Ride request do not exist.");
        }
      });
  }


}