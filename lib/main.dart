import 'package:TURF_TOWN_/src/Screens/Phone_no.dart';
import 'package:TURF_TOWN_/src/views/Home.dart';
import 'package:TURF_TOWN_/src/widgets/Navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // 👈 Add this import
import 'package:TURF_TOWN_/src/Scorecard/ScoreCard.dart';
import 'package:TURF_TOWN_/src/models/ScoreManager.dart';
import 'package:TURF_TOWN_/src/models/ScoreController.dart';
import 'package:TURF_TOWN_/src/views/Sliding_page.dart';
import 'package:TURF_TOWN_/src/Screens/advanced.settings_screen.dart';
import 'package:TURF_TOWN_/src/views/Venue.dart';
import 'package:TURF_TOWN_/src/views/alerts_page.dart';
import 'package:TURF_TOWN_/src/views/bluetooth_page.dart';
 // This file will be auto-generated

void main() {// 👈 Opens or creates your local ObjectBox database

    runApp(
      ChangeNotifierProvider(
        create: (_) => ScoreController(),
        child: FigmaToCodeApp(),
      ),
    );
  }

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ScoreManager()),
          ChangeNotifierProvider(create: (_) => ScoreController()),
          // 👈 Provide the ScoreManager globally
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SlidingPage(), // 👈 Your scoreboard page
            theme: ThemeData(
                textTheme: GoogleFonts.poppinsTextTheme(
                  Theme
                      .of(context)
                      .textTheme,
                )
            )
        )
    );
  }
}



