import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableTracking: true,
    ),
  );

  Future<List<Face>> detectFaces(InputImage image) async {
    return await _detector.processImage(image);
  }

  Future<void> dispose() async {
    await _detector.close();
  }
}