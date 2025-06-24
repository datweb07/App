import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceController {
  final SpeechToText _speech = SpeechToText();
  // Nhận diện giọng nói
  bool _speechEnabled = false;

  // Đang lắng nghe
  bool _isListening = false;

  // Callback khi nhận diện lệnh
  Function(String)? _onCommandRecognized;

  // Khởi tạo nhận diện giọng nói
  Future<void> initSpeech() async {
    var status = await Permission.microphone
        .request(); // Yêu cầu quyền truy cập
    if (status != PermissionStatus.granted) {
      print('❌ Microphone permission not granted');
      return;
    }

    // Khởi tạo SpeechToText và gắn các listener
    _speechEnabled = await _speech.initialize(
      onStatus: _statusListener,
      onError: _errorListener,
    );
  }

  // Bắt đầu lắng nghe giọng nói
  Future<void> startListening(Function(String) onCommandRecognized) async {
    if (!_speechEnabled) {
      print("🚫 Speech not initialized");
      return;
    }

    // Lưu callback
    _onCommandRecognized = onCommandRecognized;

    // Đặt trạng thái đang lắng nghe
    _isListening = true;

    // Bắt đầu lắng nghe
    _startSpeechListen();
  }

  // Đang lắng nghe
  Future<void> _startSpeechListen() async {
    if (!_isListening) return;

    print('🔁 Start listening...');
    await _speech.listen(
      localeId: 'vi_VN', // Tiếng việt
      listenFor: const Duration(seconds: 30), // Thời gian tối đa lắng nghe
      pauseFor: const Duration(seconds: 4), // Thời gian im lặng trước khi dừng
      onResult: (result) {
        final command = result.recognizedWords.toLowerCase().trim();
        print('🎙️ Recognized: $command');
        if (command.isNotEmpty) {
          _onCommandRecognized?.call(
            command,
          ); // Gọi lại callback nếu có command
        }
      },
    );
  }

  // Trạng thái nhận diện
  void _statusListener(String status) {
    print('🎤 STATUS: $status');
    if (status == 'done' || status == 'notListening') {
      // Tự động lắng nghe lại sau 500ms
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isListening) _startSpeechListen();
      });
    }
  }

  // Xử lý lỗi
  void _errorListener(SpeechRecognitionError error) {
    print('❌ ERROR: ${error.errorMsg}');
    if (_isListening) {
      // Thử lắng nghe lại 1s nếu vẫn đang ở trạng thái lắng nghe
      Future.delayed(const Duration(seconds: 1), () {
        _startSpeechListen();
      });
    }
  }

  // Dừng lắng nghe
  Future<void> stopListening() async {
    _isListening = false; // Tắt trạng thái lắng nghe
    await _speech.stop(); // Dừng nhận diện giọng nói
  }
}
