import 'package:flutter/material.dart';

class ProtectionStatus extends StatelessWidget {
  final bool enabled;

  const ProtectionStatus({
    super.key,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        enabled ? const Color(0xFF22C55E) : Colors.grey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF151522),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: 0.15),
            ),
            child: Icon(
              enabled
                  ? Icons.shield_rounded
                  : Icons.shield_outlined,
              size: 50,
              color: statusColor,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            enabled ? "PROTECTION ACTIVE" : "PROTECTION OFF",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            enabled
                ? "Your screen is being monitored"
                : "Privacy monitoring is disabled",
            style: TextStyle(
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}