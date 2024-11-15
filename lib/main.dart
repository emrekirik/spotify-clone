import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spotifyclone_app/feature/splash/splash_view.dart';
import 'package:spotifyclone_app/firebase_options.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: HexColor(backgroundColor),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: HexColor(gridColor))),
      debugShowCheckedModeBanner: false,
      home: const SplashView(),
    );
  }
}
