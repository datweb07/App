import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceController {
  final SpeechToText _speech = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  Function(String)? _onCommandRecognized;

  Future<void> initSpeech() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print('❌ Microphone permission not granted');
      return;
    }

    _speechEnabled = await _speech.initialize(
      onStatus: _statusListener,
      onError: _errorListener,
    );
  }

  Future<void> startListening(Function(String) onCommandRecognized) async {
    if (!_speechEnabled) {
      print("🚫 Speech not initialized.");
      return;
    }

    _onCommandRecognized = onCommandRecognized;
    _isListening = true;
    _startSpeechListen();
  }

  Future<void> _startSpeechListen() async {
    if (!_isListening) return;

    print('🔁 Start listening...');
    await _speech.listen(
      localeId: 'vi_VN',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4), // thời gian im lặng mới dừng
      onResult: (result) {
        final command = result.recognizedWords.toLowerCase().trim();
        print('🎙️ Recognized: $command');
        if (command.isNotEmpty) {
          _onCommandRecognized?.call(command);
        }
      },
    );
  }

  void _statusListener(String status) {
    print('🎤 STATUS: $status');
    if (status == 'done' || status == 'notListening') {
      // tự động lắng nghe lại
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isListening) _startSpeechListen();
      });
    }
  }

  void _errorListener(SpeechRecognitionError error) {
    print('❌ ERROR: ${error.errorMsg}');
    if (_isListening) {
      Future.delayed(const Duration(seconds: 1), () {
        _startSpeechListen();
      });
    }
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }
}
