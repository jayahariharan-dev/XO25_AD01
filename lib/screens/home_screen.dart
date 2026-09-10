import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../camera/camera_service.dart';
import '../detection/face_detector.dart';
import '../detection/threat_detector.dart';
import '../widgets/protection_status.dart';
import '../widgets/face_counter.dart';
import '../widgets/monitoring_card.dart';
import '../privacy/privacy_manager.dart';

import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool protectionEnabled = true;
  int faceCount = 0;
  bool _cameraReady = false;
  bool _isProcessing = false;
  bool _shieldActive = false;

  Timer? _detectionTimer;
  Timer? _shieldCheckTimer;

  final CameraService _cameraService = CameraService();
  final FaceDetectorService _faceDetector = FaceDetectorService();

  Future<void> _startBackgroundMonitoring() async {
    try {
      await const MethodChannel('lookout/background_monitoring')
          .invokeMethod('startService');

      debugPrint("BACKGROUND: Monitoring service started");
    } catch (e) {
      debugPrint("BACKGROUND SERVICE ERROR: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    _shieldCheckTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) async {
        if (!_shieldActive) return;

        final active = await FlutterOverlayWindow.isActive();

        if (!active) {
          _shieldActive = false;

          if (mounted) {
            setState(() {
              faceCount = 0;
            });
          }

          debugPrint("SHIELD: Overlay closed. Detection resumed.");
        }
      },
    );
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();

      if (!mounted) return;

      setState(() {
        _cameraReady = true;
      });

      await _startBackgroundMonitoring();

      _detectionTimer = Timer.periodic(
        const Duration(milliseconds: 700),
        (_) => _detectFaces(),
      );

      _detectionTimer = Timer.periodic(
        const Duration(milliseconds: 700),
        (_) => _detectFaces(),
      );
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
    }
  }

  Future<void> _detectFaces() async {
    if (_shieldActive) return;
    if (_isProcessing) return;

    final controller = _cameraService.controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    _isProcessing = true;

    try {
      final image = await _cameraService.captureImage();

      if (image == null) return;

      final inputImage = InputImage.fromFilePath(image.path);

      final faces = await _faceDetector.detectFaces(inputImage);

      if (!mounted) return;

      setState(() {
        faceCount = faces.length;
      });

      final threat = ThreatDetector.isThreat(faces.length);

      if (threat && !_shieldActive) {
        _shieldActive = true;

        debugPrint("SHIELD: Threat detected. Stopping detection.");

        try {
          await PrivacyManager.activatePrivacyShield();
          debugPrint("SHIELD: Privacy shield activated");
        } catch (e) {
          debugPrint("SHIELD ERROR: $e");
        }

        return;
      }

      debugPrint(
        'LOOKOUT: Faces = ${faces.length} | Threat = $threat',
      );

      // Delete temporary captured image.
      try {
        await File(image.path).delete();
      } catch (_) {}
    } catch (e) {
      debugPrint('Face detection error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _shieldCheckTimer?.cancel();
    _faceDetector.dispose();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isThreat = ThreatDetector.isThreat(faceCount);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.visibility_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'LookOut',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              const Text(
                'Public Screen Protection',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'LookOut keeps your screen private by detecting people around you.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 20),
              if (_cameraReady &&
                  _cameraService.controller != null &&
                  _cameraService.controller!.value.isInitialized)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _cameraService
                            .controller!.value.previewSize!.height,
                        height:
                            _cameraService.controller!.value.previewSize!.width,
                        child: CameraPreview(
                          _cameraService.controller!,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              const SizedBox(height: 20),
              ProtectionStatus(
                enabled: protectionEnabled,
              ),
              const SizedBox(height: 20),
              FaceCounter(
                faceCount: faceCount,
              ),
              const SizedBox(height: 20),
              const MonitoringCard(),
              const SizedBox(height: 25),
              Text(
                isThreat ? '⚠️ Privacy threat detected' : '🟢 Screen is safe',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Privacy Protection',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Switch(
                    value: protectionEnabled,
                    activeThumbColor: const Color(0xFF7C3AED),
                    onChanged: (value) {
                      setState(() {
                        protectionEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
