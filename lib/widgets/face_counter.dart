import 'package:flutter/material.dart';

class FaceCounter extends StatelessWidget {
  final int faceCount;

  const FaceCounter({
    super.key,
    required this.faceCount,
  });

  @override
  Widget build(BuildContext context) {
    final bool danger = faceCount >= 2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151522),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: (danger
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF22C55E))
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.face_rounded,
              color: danger
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF22C55E),
            ),
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "People Detected",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "$faceCount ${faceCount == 1 ? "Person" : "People"}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Spacer(),

          Icon(
            danger
                ? Icons.warning_rounded
                : Icons.check_circle_rounded,
            color: danger
                ? const Color(0xFFEF4444)
                : const Color(0xFF22C55E),
          ),
        ],
      ),
    );
  }
}