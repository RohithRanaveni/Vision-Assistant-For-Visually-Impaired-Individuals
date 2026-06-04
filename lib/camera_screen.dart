import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  final String mode;

  const CameraScreen({super.key, required this.mode});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  CameraController? controller;
  List<CameraDescription>? cameras;

  final FlutterTts flutterTts = FlutterTts();

  String selectedLanguage = "English";

  @override
  void initState() {
    super.initState();
    startCamera();
  }

  // ✅ LANGUAGE CODE
  String getLangCode() {
    switch (selectedLanguage) {
      case "Hindi":
        return "hi";
      case "Telugu":
        return "te";
      default:
        return "en";
    }
  }

  // 🔊 SPEAK
  Future<void> speakMode() async {
    await flutterTts.stop();

    String lang = getLangCode();

    if (lang == "hi") {
      await flutterTts.setLanguage("hi-IN");
    } else if (lang == "te") {
      await flutterTts.setLanguage("te-IN");
    } else {
      await flutterTts.setLanguage("en-US");
    }

    await flutterTts.speak("Mode started");
  }

  // 📷 CAMERA
  Future<void> startCamera() async {
    cameras = await availableCameras();

    controller = CameraController(
      cameras![0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();

    if (!mounted) return;

    setState(() {});

    Future.delayed(const Duration(seconds: 1), () {
      speakMode();
    });

    if(widget.mode != "Image Captioning"){
      startLiveDetection();
    }
  }

  // 🔁 FAST LOOP (REDUCED DELAY)
  void startLiveDetection() {
    Future.doWhile(() async {
      await captureImage();
      await Future.delayed(const Duration(seconds: 2)); // ⚡ faster
      return true;
    });
  }

  // 📸 CAPTURE + AI
  Future<void> captureImage() async {
    try {
      if(controller == null || !controller!.value.isInitialized) return;

      print("Selected language: $selectedLanguage");

      final image = await controller!.takePicture();

      await flutterTts.stop();
      await flutterTts.speak("Processing");

      String langCode = getLangCode();
      print("Sending language: $langCode");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("http://10.184.130.224:5000/caption"),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      request.fields['lang'] = langCode;

      var response = await request.send();

      String caption = "No result";
      List danger = [];

      if (response.statusCode == 200) {
        var data = json.decode(await response.stream.bytesToString());

        caption = data["caption"] ?? "No result";
        danger = data["danger"] ?? [];
      }

      // 🔊 OUTPUT
      if(danger.isNotEmpty){
        await flutterTts.speak("Warning ${danger.join(", ")} detected");
      } else {
        await flutterTts.speak(caption);
      }

      HapticFeedback.mediumImpact();

    } catch (e) {
      print("Error: $e");
      await flutterTts.speak("Error occurred");
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Visual Assist"),
        actions: [
          DropdownButton<String>(
            value: selectedLanguage,
            items: ["English", "Hindi", "Telugu"]
                .map((lang) => DropdownMenuItem(
                      value: lang,
                      child: Text(lang),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedLanguage = value!;
              });

              print("Selected language: $selectedLanguage");

              speakMode();
            },
          )
        ],
      ),

      body: GestureDetector(
        onDoubleTap: () {
          if(widget.mode == "Image Captioning"){
            captureImage();
          }
        },
        child: Stack(
          children: [

            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller!.value.previewSize!.height,
                  height: controller!.value.previewSize!.width,
                  child: CameraPreview(controller!),
                ),
              ),
            ),

            if(widget.mode != "Image Captioning")
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FloatingActionButton(
                    onPressed: captureImage,
                    child: const Icon(Icons.camera),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}