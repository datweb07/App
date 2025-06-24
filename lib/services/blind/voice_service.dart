import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService extends StatefulWidget {
  const VoiceService({super.key});

  @override
  _VoiceServiceState createState() => _VoiceServiceState();
}

class _VoiceServiceState extends State<VoiceService> {
  final SpeechToText _speech = SpeechToText();

  // Trạng thái nhận diện giọng nói
  bool _speechEnabled = false;
  // Lưu từ nhận diện
  String _words = "";
  // Độ chính xác
  double _confidence = 0;
  @override
  void initState() {
    super.initState();
    _initSpeech(); // Khởi tạo nhận diện ngay khi widget được tạo
  }

  Future<void> _initSpeech() async {
    var status = await Permission.microphone.request();   // Yêu cầu quyền micro
    if (status != PermissionStatus.granted) {
      print('❌ Microphone permission not granted');
      return;
    }

    _speechEnabled = await _speech.initialize(
      onStatus: (status) => print('🎤 STATUS: $status'),
      onError: (error) => print('❌ ERROR: $error'),
    );

    print('✅ Initialized: $_speechEnabled');
  }

  void _startListening() async {
    if (!_speechEnabled) {
      print("🚫 Cannot start listening: Speech not initialized.");
      return;
    }

    await _speech.listen(
      localeId: 'vi_VN',
      onResult: (result) {
        setState(() {
          _words = result.recognizedWords;
          _confidence = result.confidence;
        });
        print('🎙️ Recognized: ${result.recognizedWords}');
        _handleVoiceCommand(result.recognizedWords);
      },
    );
  }

  void _stopListening() async {
    await _speech.stop();
  }

  void _handleVoiceCommand(String command) {
    command = command.toLowerCase().trim();

    if (command.contains("bắt đầu") || command.contains("ghi âm")) {
      _startListening();
    } else if (command.contains("dừng") || command.contains("ngưng")) {
      _stopListening();
    } else if (command.contains("xóa")) {
      setState(() {
        _words = "";
      });
    } else if (command.contains("thoát")) {
      SystemNavigator.pop(); // Thoát app
    } else {
      print("⚠️ Không nhận diện được lệnh: $command");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Speech to Text', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                _speech.isListening
                    ? "listening..."
                    : _speechEnabled
                    ? "tap the button to start listening..."
                    : "speech not available",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  _words,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                ),
              ),
            ),
            if (_speech.isNotListening && _confidence > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Text(
                  "Confidence: ${(_confidence * 100).toStringAsFixed(1)}%",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _speech.isListening ? _stopListening() : _startListening();
      //   },
      //   child: Icon(_speech.isListening ? Icons.mic_off : Icons.mic),
      // ),
      floatingActionButton: SizedBox(
        width: 100,
        height: 100,
        child: FloatingActionButton(
          onPressed: () {
            _speech.isListening ? _stopListening() : _startListening();
          },
          backgroundColor: Colors.deepOrange, // màu nổi bật hơn nếu muốn
          tooltip: 'Nhấn để nói',
          child: Icon(
            _speech.isListening ? Icons.mic_off : Icons.mic,
            size: 48, // icon lớn hơn
          ),
        ),
      ),
    );
  }
}
