import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../camera/camera_service.dart';
import '../widgets/protection_status.dart';
import '../widgets/face_counter.dart';
import '../widgets/monitoring_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool protectionEnabled = true;

  // Temporary value.
  // Later this will come from ML Kit.
  int faceCount = 1;

  final CameraService _cameraService = CameraService();
  bool _cameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();

      if (mounted) {
        setState(() {
          _cameraReady = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              "LookOut",
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
                "Public Screen Protection",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "LookOut keeps your screen private by detecting people around you.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade400,
                ),
              ),

              const SizedBox(height: 20),

              // Camera preview
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
                        height: _cameraService
                            .controller!.value.previewSize!.width,
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

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Privacy Protection",
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