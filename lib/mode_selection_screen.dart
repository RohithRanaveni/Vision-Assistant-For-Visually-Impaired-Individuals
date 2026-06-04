import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'language_screen.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    speakInstructions();
  }

  Future<void> speakInstructions() async {
    await flutterTts.speak(
      "Welcome. Tap top half for Image Captioning. Tap bottom half for Live Video Description."
    );
  }

  void goToLanguage(String mode) async {

    await flutterTts.stop();
    await flutterTts.speak("You selected $mode");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LanguageScreen(mode: mode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          // IMAGE CAPTIONING
          Expanded(
            child: GestureDetector(
              onTap: () => goToLanguage("Image Captioning"),
              child: Container(
                color: Colors.blue,
                child: const Center(
                  child: Text(
                    "IMAGE CAPTIONING",
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // LIVE VIDEO
          Expanded(
            child: GestureDetector(
              onTap: () => goToLanguage("Live Video Description"),
              child: Container(
                color: Colors.green,
                child: const Center(
                  child: Text(
                    "LIVE VIDEO DESCRIPTION",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}