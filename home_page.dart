import 'package:flutter/material.dart';
import 'package:vaaig/feature_box.dart';
import 'package:vaaig/openai_service.dart';
import 'package:vaaig/pallete.dart'; // Placeholder for color palette definitions
import 'package:animate_do/animate_do.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:logger/logger.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText speechToText = SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  final Logger logger = Logger();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    try {
      await flutterTts.setSharedInstance(true);
      setState(() {});
    } catch (e) {
      logger.e('Error initializing TextToSpeech: $e');
    }
  }

  Future<void> initSpeechToText() async {
    try {
      bool available = await speechToText.initialize(
        onStatus: (status) => logger.i('SpeechToText status: $status'),
        onError: (error) => logger.e('SpeechToText error: $error'),
      );
      if (!available) {
        logger.e('Speech recognition not available.');
      }
      setState(() {});
    } catch (e) {
      logger.e('Error initializing SpeechToText: $e');
    }
  }

  Future<void> startListening() async {
    try {
      await speechToText.listen(onResult: onSpeechResult);
      setState(() {});
    } catch (e) {
      logger.e('Error starting listening: $e');
    }
  }

  Future<void> stopListening() async {
    try {
      await speechToText.stop();
      setState(() {});
    } catch (e) {
      logger.e('Error stopping listening: $e');
    }
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
    logger.i('Speech result: $lastWords');
  }

  Future<void> systemSpeak(String content) async {
    try {
      await flutterTts.speak(content);
    } catch (e) {
      logger.e('Error in systemSpeak: $e');
    }
  }

  @override
  void dispose() {
    speechToText.stop();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.lightGreenAccent,
                  Colors.lightBlueAccent,
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  title: BounceInDown(
                    child: const Text(
                      'VAAIG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  leading: const Icon(Icons.menu),
                  centerTitle: true,
                ),
                ZoomIn(
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          height: 120,
                          width: 120,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            color: Pallete.assistantCircleColor, // Placeholder for color palette usage
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Container(
                        height: 123,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/virtualAssistant.png', // Placeholder for image asset usage
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FadeInRight(
                  child: Visibility(
                    visible: generatedImageUrl == null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                        top: 30,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(20).copyWith(
                          topLeft: Radius.zero,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          generatedContent == null
                              ? 'Good Morning, what task can I do for you?'
                              : generatedContent!,
                          style: TextStyle(
                            fontFamily: 'Cera Pro',
                            color: Pallete.mainFontColor, // Placeholder for color palette usage
                            fontSize: generatedContent == null ? 25 : 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (generatedImageUrl != null)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(generatedImageUrl!),
                    ),
                  ),
                SlideInLeft(
                  child: Visibility(
                    visible: generatedContent == null && generatedImageUrl == null,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(top: 10, left: 22),
                      child: const Text(
                        'Here are a few features',
                        style: TextStyle(
                          fontFamily: 'Cera Pro',
                          color: Pallete.mainFontColor, // Placeholder for color palette usage
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: generatedContent == null && generatedImageUrl == null,
                  child: Column(
                    children: [
                      SlideInLeft(
                        delay: Duration(milliseconds: start),
                        child: const FeatureBox(
                          color: Pallete.firstSuggestionBoxColor, // Placeholder for color palette usage
                          headerText: 'ChatGPT',
                          descriptionText:
                          'A smarter way to stay organized and informed with ChatGPT',
                        ),
                      ),
                      SlideInLeft(
                        delay: Duration(milliseconds: start + delay),
                        child: const FeatureBox(
                          color: Pallete.secondSuggestionBoxColor, // Placeholder for color palette usage
                          headerText: 'Dall-E',
                          descriptionText:
                          'Get inspired and stay creative with your personal assistant powered by Dall-E',
                        ),
                      ),
                      SlideInLeft(
                        delay: Duration(milliseconds: start + 2 * delay),
                        child: const FeatureBox(
                          color: Pallete.thirdSuggestionBoxColor, // Placeholder for color palette usage
                          headerText: 'Smart Voice Assistant',
                          descriptionText:
                          'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor, // Placeholder for color palette usage
          onPressed: () async {
            if (await speechToText.hasPermission && speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              final speech = await openAIService.isArtPromptAPI(lastWords);
              if (speech.contains('https')) {
                setState(() {
                  generatedImageUrl = speech;
                  generatedContent = null;
                });
              } else {
                setState(() {
                  generatedImageUrl = null;
                  generatedContent = speech;
                });
                await systemSpeak(speech);
              }
              await stopListening();
            } else {
              await initSpeechToText();
            }
          },
          child: Icon(
            speechToText.isListening ? Icons.stop : Icons.mic,
          ),
        ),
      ),
    );
  }
}
