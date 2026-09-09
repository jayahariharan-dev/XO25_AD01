# LookOut — Public Screen Privacy Protection

> **Hackathon Project:** 24-Hour Mobile Development Hackathon  
> **Stack:** Flutter (Dart) | Google ML Kit (100% Free / On-Device)

---

## 📌 Overview
**LookOut** prevents shoulder surfing in public places. Using the device's front camera and real-time on-device Machine Learning, it automatically covers the screen with a privacy overlay when an unauthorized onlooker is detected behind or beside you.

---

## 🎯 MVP Logic

- **0 or 1 Face Detected:** Normal Screen
- **2+ Faces Detected:** 🚨 **PRIVACY PROTECTION TRIGGERED**

```text
Front Camera ──► Camera Plugin ──► ML Kit Face Counting
                                        │
      ┌─────────────────────────────────┴────────────────────────────────┐
      ▼                                                                  ▼
0 or 1 Face                                                         2+ Faces
(Normal Screen)                                             (Full-Screen Privacy Overlay
                                                              + Notification Alert)
                                                                         │
                                                                 User taps RESET
                                                                         │
                                                                         ▼
                                                                   Normal Screen
```

---

## 👥 Team Responsibilities

| Member | Focus Area | Key Deliverables |
| :--- | :--- | :--- |
| **Member 1** | Camera & ML | `camera` plugin setup, `google_mlkit_face_detection`, face count stream |
| **Member 2** | Privacy Overlay | Full-screen privacy cover UI widget, reset trigger logic |
| **Member 3** | UI & Notifications | Main Flutter UI, `flutter_local_notifications`, permissions handling, testing |

---

## ⚡ Technical Stack (100% Free)

- **Framework:** Flutter (Dart)
- **Camera:** `camera` Flutter package
- **ML Engine:** `google_mlkit_face_detection` (On-device, offline, zero cost)
- **Overlay:** Full-screen Stack Widget / Flutter Overlay Entry
- **Notifications:** `flutter_local_notifications` package

---

## 🚀 Quick Setup & Dependencies

### 1. Dependencies (`pubspec.yaml`)
```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5+9
  google_mlkit_face_detection: ^0.10.0
  flutter_local_notifications: ^17.0.0
  permission_handler: ^11.3.0
```

### 2. Camera & ML Kit Face Counting Logic (`face_detector_service.dart`)
```dart
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  bool _isProcessing = false;

  Future<void> processCameraImage(
    CameraImage image, 
    CameraDescription camera, 
    Function(int) onFaceCount,
  ) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg,
        format: InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    final faces = await _faceDetector.processImage(inputImage);
    onFaceCount(faces.length);
    _isProcessing = false;
  }

  void dispose() {
    _faceDetector.close();
  }
}
```

---

## 🔒 Privacy Guarantee
- **No storage:** Camera frames are processed directly in memory and immediately discarded.
- **No network use:** 100% on-device processing. No video feeds or photos leave the device.
