import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'dart:typed_data'; // Added for Uint8List
import '../providers/language_provider.dart';
import '../config/theme.dart';

class ARModeScreen extends StatefulWidget {
  const ARModeScreen({Key? key}) : super(key: key);

  @override
  _ARModeScreenState createState() => _ARModeScreenState();
}

class _ARModeScreenState extends State<ARModeScreen> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  String _detectedText = '';
  String _translatedText = '';
  bool _isProcessing = false;
  TextRecognizer? _textRecognizer;

  @override
  void initState() {
    super.initState();
    _initializeRecognizer();
    if (kIsWeb || !(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      setState(() {
        _detectedText = 'AR Mode is only supported on Android and iOS devices. Web is not supported.';
      });
    } else {
      _requestCameraPermission();
    }
  }

  void _initializeRecognizer() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final sourceLang = languageProvider.sourceLanguage;
    _textRecognizer = TextRecognizer(
      script: sourceLang == 'ko' ? TextRecognitionScript.korean : TextRecognitionScript.latin,
    );
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          _detectedText = 'Camera permission denied';
        });
        return;
      }
    }
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _detectedText = 'No camera available';
        });
        return;
      }

      _controller = CameraController(_cameras[0], ResolutionPreset.medium);
      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      _controller!.startImageStream((image) async {
        if (_isProcessing || _textRecognizer == null) return;
        _isProcessing = true;

        try {
          final inputImage = _createInputImageFromCameraImage(image, _controller!);
          final recognizedText = await _textRecognizer!.processImage(inputImage);
          if (recognizedText.text.isNotEmpty) {
            setState(() {
              _detectedText = recognizedText.text;
            });

            final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
            await languageProvider.translateSpeech(_detectedText);
            setState(() {
              _translatedText = languageProvider.speechTranslation ?? 'Translation unavailable';
            });
          } else {
            setState(() {
              _detectedText = 'No text detected. Ensure clear, well-lit text.';
            });
          }
        } catch (e) {
          setState(() {
            _detectedText = 'Error detecting text: $e';
          });
        } finally {
          _isProcessing = false;
        }
      });
    } catch (e) {
      setState(() {
        _detectedText = 'Camera initialization failed: $e';
      });
    }
  }

  InputImage _createInputImageFromCameraImage(CameraImage image, CameraController controller) {
    final sensorOrientation = controller.description.sensorOrientation;
    InputImageRotation rotation;
    switch (sensorOrientation) {
      case 90:
        rotation = InputImageRotation.rotation90deg;
        break;
      case 180:
        rotation = InputImageRotation.rotation180deg;
        break;
      case 270:
        rotation = InputImageRotation.rotation270deg;
        break;
      default:
        rotation = InputImageRotation.rotation0deg;
    }

    return InputImage.fromBytes(
      bytes: _concatenatePlanes(image.planes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.yuv420,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final List<int> allBytes = [];
    for (final plane in planes) {
      allBytes.addAll(plane.bytes);
    }
    return Uint8List.fromList(allBytes);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AR Mode - Scan & Translate',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_isCameraInitialized && !kIsWeb)
            CameraPreview(_controller!)
          else
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.backgroundGradient, // Navy-to-black gradient
              ),
              child: Center(
                child: _detectedText.isNotEmpty
                    ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _detectedText,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.primaryNavy,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                    : const CircularProgressIndicator(
                  color: AppTheme.accentGold,
                ),
              ),
            ),
          if (_isCameraInitialized && !kIsWeb)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detected Text: $_detectedText',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Translation (${languageProvider.targetLanguage}): $_translatedText',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.primaryNavy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_translatedText.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.volume_up),
                              color: AppTheme.accentTeal,
                              onPressed: () {
                                languageProvider.speak(_translatedText, languageProvider.targetLanguage!);
                              },
                              tooltip: 'Play translation pronunciation',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}