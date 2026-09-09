import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class PrivacyOverlayWidget extends StatelessWidget {
  const PrivacyOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.92),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_rounded,
              size: 70,
              color: Color(0xFF7C3AED),
            ),
            const SizedBox(height: 20),
            const Text(
              "⚠️ PRIVACY SHIELD ACTIVE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Multiple faces detected.\nScreen protected.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                debugPrint("OVERLAY: RESET button pressed");

                try {
                  final result = await FlutterOverlayWindow.closeOverlay();
                  debugPrint("OVERLAY: close result = $result");
                } catch (e) {
                  debugPrint("OVERLAY CLOSE ERROR: $e");
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text(
                "RESET PROTECTION",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
