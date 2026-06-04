import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'camera_screen.dart';

class LanguageScreen extends StatefulWidget {

  final String mode;

  const LanguageScreen({super.key, required this.mode});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    speakInstruction();
  }

  Future speakInstruction() async {
    await flutterTts.speak(
      "Select language. Top for Telugu. Middle for Hindi. Bottom for English."
    );
  }

  void openCamera(String language) async {

    await flutterTts.stop();
    await flutterTts.speak("$language selected");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(mode: widget.mode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          // TELUGU
          Expanded(
            child: GestureDetector(
              onTap: () => openCamera("Telugu"),
              child: Container(
                color: Colors.orange,
                child: const Center(
                  child: Text("TELUGU",
                      style: TextStyle(fontSize: 28, color: Colors.white)),
                ),
              ),
            ),
          ),

          // HINDI
          Expanded(
            child: GestureDetector(
              onTap: () => openCamera("Hindi"),
              child: Container(
                color: Colors.purple,
                child: const Center(
                  child: Text("HINDI",
                      style: TextStyle(fontSize: 28, color: Colors.white)),
                ),
              ),
            ),
          ),

          // ENGLISH
          Expanded(
            child: GestureDetector(
              onTap: () => openCamera("English"),
              child: Container(
                color: Colors.teal,
                child: const Center(
                  child: Text("ENGLISH",
                      style: TextStyle(fontSize: 28, color: Colors.white)),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}