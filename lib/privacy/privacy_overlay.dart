import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

// This entry point is mandatory for the background isolate to render the overlay
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PrivacyOverlayWidget(),
    ),
  );
}

class PrivacyOverlayWidget extends StatelessWidget {
  const PrivacyOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.95), // Dark privacy shield
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            const Text(
              "SHIELD ACTIVE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Intruder detected! Screen obscured.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                // Close the overlay window when dismissed manually
                await FlutterOverlayWindow.closeOverlay();
              },
              child: const Text("Dismiss Shield", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}