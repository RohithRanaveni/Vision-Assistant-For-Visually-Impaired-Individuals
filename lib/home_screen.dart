import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'language_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    speakInstructions();
  }

  Future speakInstructions() async {
    await flutterTts.speak(
      "Welcome. Tap top half for Image Captioning. Tap bottom half for Live Video Description."
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          // IMAGE CAPTIONING BUTTON
          Expanded(
            child: GestureDetector(
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageScreen(),
                  ),
                );

              },
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

          // LIVE VIDEO DESCRIPTION BUTTON
          Expanded(
            child: GestureDetector(
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageScreen(),
                  ),
                );

              },
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