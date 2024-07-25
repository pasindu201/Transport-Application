import 'package:flutter/material.dart';
import 'user_screens/forgot_password_screen.dart';
import 'user_screens/login_screen.dart';
import 'user_screens/main_screen.dart';
import 'user_screens/register_screen.dart';
import '../splash_screen/splash_screen.dart';
import '../theme_provider/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'user_widgets/pay_fare_amount_dialog.dart';
import 'user_infoHandler/app_info.dart';
import 'package:provider/provider.dart';

import 'user_screens/search_places-screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AppInfo(),
        child: MaterialApp(
          title: 'Flutter Demo',
          themeMode: ThemeMode.system,
          theme: MyThemes.lightTheme,
          darkTheme: MyThemes.darkTheme,
          home: SplashScreen(),
        )
    );
  }
}



