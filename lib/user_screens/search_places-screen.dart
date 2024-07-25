import 'package:flutter/material.dart';
import '../user_assistants/request_assistant.dart';
import '../user_global/map_key.dart';
import '../user_models/predicted_places.dart';
import '../user_widgets/place_prediction_tile.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {

  List<PredictedPlaces> placesPredictedList = [];

  findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapkey&components=country:LK";

      print("URL: $urlAutoCompleteSearch"); // Debug: Print URL

      var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if (responseAutoCompleteSearch == "Error Occured. Failed. No Response.") {
        print("Error: No response from the API"); // Debug: Print error message
        return;
      }

      if (responseAutoCompleteSearch["status"] == "OK") {
        var placePredictions = responseAutoCompleteSearch["predictions"];
        var placePredictionsList = (placePredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();

        setState(() {
          placesPredictedList = placePredictionsList;
        });

        print("Places predicted list updated."); // Debug: Print success message
      } else {
        print("Error: ${responseAutoCompleteSearch["status"]}"); // Debug: Print API status
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: darkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: darkTheme? Colors.amber.shade400 : Colors.blue,
          leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: darkTheme ? Colors.black : Colors.white,)
          ),
          title: Text(
            "Search & Set Destination",
            style: TextStyle(color: darkTheme? Colors.black : Colors.white),
          ),
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: darkTheme? Colors.amber.shade400 : Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    )
                  )
                ]
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.adjust_sharp,
                        color: darkTheme? Colors.black : Colors.white,
                        ),
                        SizedBox(height: 18.0,),
                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: TextField(
                                onChanged: (value){
                                  findPlaceAutoCompleteSearch(value);
                                },
                                decoration: InputDecoration(
                                  hintText: "Search location here...",
                                  fillColor: darkTheme? Colors.black : Colors.white54,
                                  filled: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 11,
                                      top:8,
                                      bottom: 8
                                  )
                                ),
                              ),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ),
            // display place prediction result
            (placesPredictedList.length>0) ?
                Expanded(
                    child: ListView.separated(
                        itemCount: placesPredictedList.length,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return PlacePredictionTileDesign(
                            predictedPlaces: placesPredictedList[index],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index){
                          return Divider(
                            height: 0,
                            color: darkTheme? Colors.amber.shade400 : Colors.blue,
                            thickness: 0,
                          );
                        },
                    ),
                ) : Container()
          ],
        ),
      ),
    );
  }
}

