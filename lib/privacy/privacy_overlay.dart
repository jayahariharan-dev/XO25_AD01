import 'package:flutter/material.dart';

class PrivacyOverlayWidget extends StatelessWidget {
  const PrivacyOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.9),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_rounded,
              size: 64,
              color: Color(0xFF7C3AED),
            ),
            SizedBox(height: 16),
            Text(
              "⚠️ PRIVACY SHIELD ACTIVE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Multiple faces detected. Screen protected.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}