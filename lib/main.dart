import 'package:TURF_TOWN_/src/services/bluetooth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:TURF_TOWN_/src/models/objectbox_helper.dart';
import 'package:TURF_TOWN_/src/views/splash_screen_new.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ObjectBox before running the app
  await ObjectBoxHelper.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Listen to app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // 🔥 FIX: Don't disconnect Bluetooth here - it kills connection on page navigation
    // Bluetooth should only disconnect on explicit user action or real app termination
    // The didChangeAppLifecycleState handles app detached state
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Optional: Handle app lifecycle states
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('📱 App resumed - Bluetooth stays connected');
        break;
      case AppLifecycleState.paused:
        debugPrint('📱 App paused - Bluetooth stays connected');
        break;
      case AppLifecycleState.detached:
        // 🔥 ONLY disconnect when app is actually closing (detached)
        // NOT when navigating between pages
        debugPrint('📱 App detached - Disconnecting Bluetooth');
        BleManagerService().disconnect();
        break;
      case AppLifecycleState.inactive:
        // 🔥 FIX: Do NOT disconnect on inactive - this happens during navigation
        debugPrint('📱 App inactive - Bluetooth stays connected');
        break;
      case AppLifecycleState.hidden:
        debugPrint('📱 App hidden - Bluetooth stays connected');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreenNew(),
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}
