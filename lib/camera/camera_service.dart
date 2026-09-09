import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;

  Future<void> initialize() async {
    final cameras = await availableCameras();

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();
  }

  Future<XFile?> captureImage() async {
    if (controller == null ||
        !controller!.value.isInitialized ||
        controller!.value.isTakingPicture) {
      return null;
    }

    return await controller!.takePicture();
  }

  Future<void> dispose() async {
    await controller?.dispose();
    controller = null;
  }
}