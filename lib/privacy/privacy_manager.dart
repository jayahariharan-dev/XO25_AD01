import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class PrivacyManager {
  // Call this method when an intruder is detected to trigger the shield
  static Future<void> activatePrivacyShield() async {
    // Check if the overlay permission is granted first
    bool isGranted = await FlutterOverlayWindow.isPermissionGranted();
    
    if (isGranted) {
      // Show the overlay window defined by our overlayMain entry point
      await FlutterOverlayWindow.showOverlay(
        enableDrag: false,
        flag: OverlayFlag.defaultFlag,
        alignment: OverlayAlignment.center,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.none,
      );
    } else {
      // Request permission if not already granted
      await FlutterOverlayWindow.requestPermission();
    }
    
  }

  // Call this method when the threat is gone to dismiss the shield
  static Future<void> deactivatePrivacyShield() async {
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }
}