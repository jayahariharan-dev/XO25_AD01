# LookOut — Public Screen Privacy Protection

> **Hackathon Project:** 24-Hour Android Development Hackathon  
> **Stack:** Android (Kotlin) | CameraX | Google ML Kit (100% Free / On-Device)

---

## 📌 Overview
**LookOut** prevents shoulder surfing in public places. Using the front camera and real-time on-device Machine Learning, it automatically covers the screen when an unauthorized onlooker is detected.

---

## 🎯 MVP Logic

- **0 or 1 Face Detected:** Normal Screen
- **2+ Faces Detected:** 🚨 **PRIVACY PROTECTION TRIGGERED**

```text
Front Camera ──► CameraX ──► ML Kit Face Counting
                                  │
      ┌───────────────────────────┴──────────────────────────┐
      ▼                                                      ▼
0 or 1 Face                                               2+ Faces
(Normal Screen)                                   (Full-Screen Cover + Notification)
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
| **Member 1** | Camera & ML | `CameraX` setup, `FaceAnalyzer.kt`, face count logic |
| **Member 2** | Protection & Overlay | Privacy overlay screen/service, RESET action |
| **Member 3** | UI & Notifications | `MainActivity`, permissions, `NotificationHelper`, end-to-end testing |

---

## ⚡ Technical Stack (100% Free)

- **Language:** Kotlin (Android Studio)
- **Camera:** CameraX API
- **ML Engine:** Google ML Kit Face Detection (On-device, offline, zero cost)
- **Protection:** System Overlay / Full-Screen Activity Cover
- **Notifications:** Android NotificationManager

---

## 🚀 Quick Setup & Dependencies

### 1. Permissions (`AndroidManifest.xml`)
```xml
<uses-feature android:name="android.hardware.camera.any" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### 2. Dependencies (`build.gradle.kts`)
```kotlin
dependencies {
    // CameraX
    implementation("androidx.camera:camera-core:1.3.2")
    implementation("androidx.camera:camera-camera2:1.3.2")
    implementation("androidx.camera:camera-lifecycle:1.3.2")
    implementation("androidx.camera:camera-view:1.3.2")

    // Google ML Kit Face Detection (Free / On-Device)
    implementation("com.google.mlkit:face-detection:16.1.6")
}
```

### 3. Face Analyzer Core Logic (`FaceAnalyzer.kt`)
```kotlin
class FaceAnalyzer(private val onFaceCountChanged: (Int) -> Unit) : ImageAnalysis.Analyzer {
    private val detector = FaceDetection.getClient(
        FaceDetectorOptions.Builder()
            .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_FAST)
            .build()
    )

    @OptIn(ExperimentalGetImage::class)
    override fun analyze(imageProxy: ImageProxy) {
        val mediaImage = imageProxy.image
        if (mediaImage != null) {
            val image = InputImage.fromMediaImage(mediaImage, imageProxy.imageInfo.rotationDegrees)
            detector.process(image)
                .addOnSuccessListener { faces -> onFaceCountChanged(faces.size) }
                .addOnCompleteListener { imageProxy.close() }
        } else {
            imageProxy.close()
        }
    }
}
```

---

## 🔒 Privacy Guarantee
- **No storage:** Camera frames are processed instantly in memory and immediately discarded.
- **No network use:** 100% on-device processing. No images leave the phone.
