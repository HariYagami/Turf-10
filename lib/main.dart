import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:TURF_TOWN_/src/models/objectbox_helper.dart';
import 'package:TURF_TOWN_/src/views/Sliding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize ObjectBox before running the app
  await ObjectBoxHelper.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SlidingPage(),
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}
