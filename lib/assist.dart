import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

class assist extends StatefulWidget {
  const assist({super.key});

  @override
  _assistState createState() => _assistState();
}

class _assistState extends State<assist> {
  
  String api = "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";
  final SpeechToText speech = SpeechToText();
  bool enabled = false;
  String words = '';
  String response = '';
  bool loading = false;
  final FlutterTts tts = FlutterTts();
  String lang = "en-IN"; 

  @override
  void initState() {
    super.initState();
    onSpeech();
    initAsyncSettings(); 
  }

  Future<void> initAsyncSettings() async {
    await getLocal();      
    await tts.setLanguage(lang); 
    await tts.setSpeechRate(0.5);
    await tts.setPitch(1.0);
  }

  @override
  void dispose() {
    speech.stop();
    tts.stop();
    super.dispose();
  }

  
  Future<void> getLocal() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedLang = prefs.getString("lang");

    if (savedLang != null && savedLang.isNotEmpty) {
      setState(() {
        lang = savedLang;
      });
    }
  }

  void onSpeech() async {
    enabled = await speech.initialize();
    if (mounted) setState(() {});
  }

  void _startListening() async {
    words = ''; 
    await speech.listen(
      onResult: results,
      localeId: lang,
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 3),
    );
    setState(() {});
  }

  void _stopListening() async {
    await speech.stop();
    setState(() {});
  }

  void results(SpeechRecognitionResult result) {
    setState(() {
      words = result.recognizedWords;
    });

    if (result.finalResult) {
      getAIResponse(words);
    }
  }

  Future<void> getAIResponse(String question) async {
    if (loading || question.trim().isEmpty) return;

    setState(() {
      loading = true;
    });

    try {
      final responseApi = await http.post(
        Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $api",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content": "reply in < 15 words, language layout format matching: $lang,"
            },
            {
              "role": "user",
              "content": question
            }
          ]
        }),
      );

      final data = jsonDecode(responseApi.body);
      String answer = data["choices"][0]["message"]["content"];

      setState(() {
        response = answer;
      });

      await tts.stop();
      await tts.speak(answer);

    } catch (e) {
      setState(() {
        response = "Error: $e";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isListening = speech.isListening; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant',
            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 1.5 )),
        backgroundColor: Colors.cyan,
        centerTitle: true,
        toolbarHeight: 100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                Icon(isListening ? Icons.spatial_audio : Icons.spatial_audio_off, color: isListening ? Colors.red : Colors.black),
                const Text(
                  " (You)",
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              words.isEmpty ? "..." : words,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 60),
            Row(
              children: [
                const Icon(Icons.smart_toy),
                const Text(
                  " (Assistant)",
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 15),
            loading
                ? const CircularProgressIndicator()
                : Text(response.isEmpty ? "..." : response, style: const TextStyle(fontSize: 20)),
            const Spacer(), 
            Center(
              child: Text(
                isListening ? "Listening..." : "Tap Mic And Start Speaking", 
                style: TextStyle(fontSize: 20, color: isListening ? Colors.red : Colors.grey[700]),
              )
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, 
      floatingActionButton: FloatingActionButton(
        onPressed: isListening ? _stopListening : _startListening,
        backgroundColor: isListening ? Colors.red : Colors.cyan,
        tooltip: 'Listen',
        child: Icon(isListening ? Icons.mic : Icons.mic_off, color: Colors.white,),
      ),
    );
  }
}