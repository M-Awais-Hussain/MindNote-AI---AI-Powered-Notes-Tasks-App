import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isEnabled = false;
  String _lastRecognizedWords = '';

  /// Request microphone permission from the user
  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    print('Voice: Current microphone permission status: $status');

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.microphone.request();
      print('Voice: Permission request result: $result');
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      print(
          'Voice: Microphone permission permanently denied. Opening settings...');
      await openAppSettings();
      return false;
    }

    return false;
  }

  Future<bool> initialize() async {
    // First, request microphone permission
    final hasPermission = await _requestMicrophonePermission();
    if (!hasPermission) {
      print('Voice: Microphone permission not granted');
      return false;
    }

    _isEnabled = await _speechToText.initialize(
      onError: (val) => print('Voice Error: $val'),
      onStatus: (val) => print('Voice Status: $val'),
    );
    print('Voice: Speech-to-text initialized: $_isEnabled');
    return _isEnabled;
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function(bool) onListeningStateChanged,
  }) async {
    if (!_isEnabled) {
      final available = await initialize();
      if (!available) {
        print('Voice: Speech-to-text not available');
        return;
      }
    }

    _lastRecognizedWords = '';
    onListeningStateChanged(true);

    await _speechToText.listen(
      onResult: (result) {
        print(
            'Voice result: ${result.recognizedWords}, final: ${result.finalResult}');
        // Always update to the latest recognized words
        _lastRecognizedWords = result.recognizedWords;
        // Pass the result to the callback
        onResult(result.recognizedWords);
      },
      listenFor: const Duration(seconds: 30),
      // Don't specify localeId - use device's default speech recognition language
      cancelOnError: false,
      partialResults: true,
    );
  }

  Future<void> stopListening(Function(bool) onListeningStateChanged) async {
    await _speechToText.stop();
    onListeningStateChanged(false);
  }

  bool get isListening => _speechToText.isListening;
  String get lastRecognizedWords => _lastRecognizedWords;
}
