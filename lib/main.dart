import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SmartCamApp());
}

class SmartCamApp extends StatelessWidget {
  const SmartCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ControlScreen(),
    );
  }
}

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {

  // 🔒 FIXED SERVER IP (YOUR LAPTOP)
  String serverIP = "http://10.193.189.49:5000";

  // 🔄 CHANGE ONLY THIS (ESP32)
  String espIP = "http://10.193.189.62";

  double angle = 90;
  bool flashOn = false;
  String status = "CONNECTING...";
  int refresh = 0;

  @override
  void initState() {
    super.initState();

    startStatusUpdater();

    Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (mounted) {
        setState(() {
          refresh++;
        });
      }
    });
  }

  // 🔄 ONLY ESP IP INPUT
  void showIPDialog() {
    TextEditingController ipController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set ESP IP"),
          content: TextField(
            controller: ipController,
            decoration: const InputDecoration(
              labelText: "Enter ESP IP (e.g. 10.193.189.62)",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (ipController.text.isNotEmpty) {
                  setState(() {
                    espIP = "http://${ipController.text.trim()}";
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // 📊 STATUS (FROM FLASK)
  void startStatusUpdater() {
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final res = await http.get(Uri.parse("$serverIP/status"));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);

          if (mounted) {
            setState(() {
              status = data["status"] ?? "NO DATA";
            });
          }
        } else {
          if (mounted) {
            setState(() {
              status = "SERVER ERROR";
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            status = "OFFLINE";
          });
        }
      }
    });
  }

  // 🎚️ SERVO (ESP32)
  void setServo(double value) async {
    setState(() => angle = value);

    try {
      await http.get(Uri.parse("$espIP/servo?angle=${value.toInt()}"));
    } catch (e) {}
  }

  // 🔦 FLASH (ESP32)
  void toggleFlash() async {
    flashOn = !flashOn;
    setState(() {});

    try {
      if (flashOn) {
        await http.get(Uri.parse("$espIP/control?var=led_intensity&val=255"));
      } else {
        await http.get(Uri.parse("$espIP/control?var=led_intensity&val=0"));
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A1A),

      body: SafeArea(
        child: Column(
          children: [

            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "SURVEILLANCE",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: showIPDialog,
                  ),
                ],
              ),
            ),

            // STATUS BAR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: status.contains("OFFLINE")
                    ? Colors.red.withOpacity(0.3)
                    : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    status.contains("OFFLINE")
                        ? Icons.error
                        : Icons.check_circle,
                    color: status.contains("OFFLINE")
                        ? Colors.red
                        : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🎥 VIDEO (FROM FLASK)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(
                        "$serverIP/snapshot?$refresh",
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text(
                              "No Video",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🎮 CONTROLS
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2A2A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("SERVO CONTROL"),
                      Text("${angle.toInt()}°"),
                    ],
                  ),

                  Slider(
                    value: angle,
                    min: 0,
                    max: 180,
                    activeColor: Colors.blueAccent,
                    onChanged: setServo,
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text("RELAY OFF"),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: toggleFlash,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: flashOn
                                ? Colors.orange.withOpacity(0.4)
                                : Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            flashOn
                                ? Icons.flash_on
                                : Icons.flash_off,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}