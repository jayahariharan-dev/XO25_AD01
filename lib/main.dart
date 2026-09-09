import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'privacy/privacy_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LookOutApp());
}

// MANDATORY: Entry point for the floating overlay window
@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PrivacyOverlayWidget(),
    ),
  );
}

class LookOutApp extends StatelessWidget {
  const LookOutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LookOut',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0B12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}