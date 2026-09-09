import 'package:flutter/material.dart';
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
        child: Padding(
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

              const SizedBox(height: 30),

              ProtectionStatus(
                enabled: protectionEnabled,
              ),

              const SizedBox(height: 20),

              FaceCounter(
                faceCount: faceCount,
              ),

              const SizedBox(height: 20),

              const MonitoringCard(),

              const Spacer(),

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
                    activeColor: const Color(0xFF7C3AED),
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