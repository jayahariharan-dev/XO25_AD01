import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter/foundation.dart';

class PrivacyManager {
  static bool _isShieldActive = false;

  static Future<void> activatePrivacyShield() async {
    try {
      bool? hasPermission = await FlutterOverlayWindow.isPermissionGranted();
      if (hasPermission != true) {
        hasPermission = await FlutterOverlayWindow.requestPermission();
        if (hasPermission != true) return;
      }

      bool isActive = await FlutterOverlayWindow.isActive();

      if (!isActive && !_isShieldActive) {
        _isShieldActive = true;
        await FlutterOverlayWindow.showOverlay(
          enableDrag: false,
          flag: OverlayFlag.defaultFlag,
          alignment: OverlayAlignment.center,
          visibility: NotificationVisibility.visibilityPublic,
          positionGravity: PositionGravity.none,
        );
      }
    } catch (e) {
      debugPrint("Overlay activation error: $e");
    }
  }

  static Future<void> deactivatePrivacyShield() async {
    try {
      bool isActive = await FlutterOverlayWindow.isActive();
      if (isActive && _isShieldActive) {
        _isShieldActive = false;
        FlutterOverlayWindow.closeOverlay();
      }
    } catch (e) {
      debugPrint("Overlay close error: $e");
    }
  }
}
