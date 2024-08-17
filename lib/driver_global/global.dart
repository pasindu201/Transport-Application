import 'dart:async';
import '../driver_models/driver_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../driver_models/direction_details_info.dart';
import '../driver_models/user_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

UserModel? userModelCurrentinfo;

Position? driverCurrentPosition;

DriverData onlineDriverData = DriverData();

String? driverVehicleType;

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();


