import 'package:firebase_auth/firebase_auth.dart';
import '../user_models/direction_details_info.dart';
import '../user_models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

UserModel? userModelCurrentinfo;
String userDropOffAddress = "";
DirectionDetailsInfo? tripDirectionDetailsInfo;

String driverCarDetails = "";
String driverName = "";
String driverPhone ="";

double countRatingStars = 0.0;
String titleStarsRating = "";

List driversList = [];
