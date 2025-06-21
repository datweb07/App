import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_nckh/components/drawer.dart';
import 'package:demo_nckh/services/blind/translateObject.dart';
import 'package:demo_nckh/services/blind/voice_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ObjectRecognitionScreen extends StatefulWidget {
  const ObjectRecognitionScreen({super.key});

  @override
  State<ObjectRecognitionScreen> createState() =>
      _ObjectRecognitionScreenState();
}

class _ObjectRecognitionScreenState extends State<ObjectRecognitionScreen> {
  final VoiceController voiceController = VoiceController();
  bool isVoiceListening = false;
  String? _lastCommand;
  bool _isTTSSpeaking = false;

  // Camera và ML Kit
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  // ML Kit
  late ObjectDetector _objectDetector;
  late ImageLabeler _imageLabeler;

  // Text to Speech
  final FlutterTts _flutterTts = FlutterTts();

  // Trạng thái ứng dụng
  bool _isProcessing = false;
  String _lastDetectedObjects = '';
  String _statusMessage = 'Sẵn sàng nhận diện vật thể';

  // Cài đặt
  bool _continuousMode = false;
  double _speechRate = 0.5;
  double _speechPitch = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeApp();
  }

  // Phương thức tải cài đặt khi khởi động app
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _speechRate = prefs.getDouble('speech_rate') ?? 0.5;
      _speechPitch = prefs.getDouble('speech_pitch') ?? 1.0;
      _continuousMode = prefs.getBool('continuous_mode') ?? false;
    });

    // Áp dụng cài đặt cho TTS
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_speechPitch);
  }

  // Phương thức lưu cài đặt
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('speech_rate', _speechRate);
    await prefs.setDouble('speech_pitch', _speechPitch);
    await prefs.setBool('continuous_mode', _continuousMode);
  }

  Future<void> _initializeApp() async {
    await _requestPermissions();
    await _initializeCamera();
    await _initializeMLKit();
    await _initializeTTS();
    // await _initializeSpeechToText();

    await _initializeVoiceControl();

    await _speak(
      "Chào mừng bạn đến với ứng dụng nhận diện vật thể. Chạm vào màn hình để bắt đầu nhận diện.",
    );
  }

  Future<void> _initializeVoiceControl() async {
    try {
      await voiceController.initSpeech();
      // Bắt đầu nghe ngay sau khi khởi tạo
      await _startContinuousListening();
      _updateStatus("Sẵn sàng nhận diện vật thể. Micro đang hoạt động.");
    } catch (e) {
      print("Lỗi khởi tạo voice control: $e");
      _updateStatus("Lỗi khởi tạo micro: $e");
    }
  }

  Future<void> _startContinuousListening() async {
    if (!_isTTSSpeaking) {
      try {
        await voiceController.startListening(_handleVoiceCommand);
        setState(() {
          isVoiceListening = true;
        });
        print("🎤 Bắt đầu nghe giọng nói");
      } catch (e) {
        print("❌ Lỗi khi bắt đầu nghe: $e");
        // Retry sau 2 giây
        Future.delayed(Duration(seconds: 2), () {
          if (!_isTTSSpeaking) {
            _startContinuousListening();
          }
        });
      }
    }
  }

  Future<void> _stopListeningTemporarily() async {
    if (isVoiceListening) {
      try {
        await voiceController.stopListening();
        setState(() {
          isVoiceListening = false;
        });
        print("⏸️ Tạm dừng nghe giọng nói");
      } catch (e) {
        print("❌ Lỗi khi dừng nghe: $e");
      }
    }
  }

  void _handleVoiceCommand(String command) async {
    // Tránh xử lý lệnh trùng lặp
    if (_lastCommand == command &&
        DateTime.now()
                .difference(_lastCommandTime ?? DateTime.now())
                .inSeconds <
            3) {
      print("Lệnh '$command' đã được thực hiện gần đây, bỏ qua");
      return;
    }
    _lastCommand = command;
    _lastCommandTime = DateTime.now();

    print("Nhận lệnh: $command");

    if (command.contains("thoát ứng dụng") ||
        command.contains("đóng ứng dụng")) {
      await _flutterTts.speak("Đang thoát ứng dụng");
      SystemNavigator.pop();
    } else if (command.contains("tắt micro") ||
        command.contains("ngừng nghe")) {
      await _stopListeningTemporarily();
      await _flutterTts.speak("Đã tắt chế độ nghe giọng nói");
    } else if (command.contains("bật micro") || command.contains("nghe lại")) {
      await _startContinuousListening();
      await _flutterTts.speak("Đã bật chế độ nghe giọng nói");
    } else if (command.contains("thông tin tài khoản") ||
        command.contains("tài khoản của tôi")) {
      await _flutterTts.speak("Mở thông tin tài khoản");
      _speakUserName();
      _showUserInfoDialog(context);
    } else if (command.contains("Đóng thông tin tài khoản") ||
        command.contains("đóng tài khoản")) {
      await _flutterTts.speak("Đã đóng thông tin tài khoản");
      Navigator.pop(context);
    } else if (command.contains('chụp') || command.contains('nhận diện')) {
      _captureAndAnalyze();
    } else if (command.contains('lặp lại')) {
      if (_lastDetectedObjects.isNotEmpty) {
        _speak(_lastDetectedObjects);
      } else {
        _speak("Chưa có thông tin nào để lặp lại");
      }
    } else if (command.contains('trợ giúp')) {
      _speak("Bạn có thể nói: chụp ảnh, nhận diện, lặp lại, hoặc trợ giúp");
    } else if (command.contains("Mở cài đặt")) {
      await _speak("Đang mở cài đặt");
      _showSettingsDialog();
    }
  }

  // Thêm biến để theo dõi thời gian lệnh cuối
  DateTime? _lastCommandTime;

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.speech,
    ].request();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0], // Camera sau
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
        print("Camera khởi tạo thành công");
      }
    } catch (e) {
      print("Lỗi khởi tạo camera: $e"); // Debug
      _updateStatus("Lỗi khởi tạo camera: $e");
    }
  }

  Future<void> _initializeMLKit() async {
    try {
      // Cấu hình Object Detector
      final objectDetectorOptions = ObjectDetectorOptions(
        mode: DetectionMode.single,
        classifyObjects: true,
        multipleObjects: true,
      );
      _objectDetector = ObjectDetector(options: objectDetectorOptions);

      // Cấu hình Image Labeler
      final imageLabelerOptions = ImageLabelerOptions(confidenceThreshold: 0.7);
      _imageLabeler = ImageLabeler(options: imageLabelerOptions);

      print("ML Kit khởi tạo thành công");
    } catch (e) {
      print("Lỗi khởi tạo ML Kit: $e");
    }
  }

  Future<void> _initializeTTS() async {
    try {
      await _flutterTts.setLanguage("vi-VN");
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(_speechPitch);
      await _flutterTts.setVolume(1.0);

      // Thiết lập callback để theo dõi trạng thái TTS
      _flutterTts.setStartHandler(() {
        setState(() {
          _isTTSSpeaking = true;
        });
        _stopListeningTemporarily(); // Tạm dừng micro khi TTS bắt đầu
      });

      _flutterTts.setCompletionHandler(() {
        setState(() {
          _isTTSSpeaking = false;
        });
        // Khởi động lại micro sau khi TTS hoàn thành
        Future.delayed(Duration(milliseconds: 800), () {
          _startContinuousListening();
        });
      });

      _flutterTts.setErrorHandler((msg) {
        print("❌ TTS lỗi: $msg");
        setState(() {
          _isTTSSpeaking = false;
        });
        // Khởi động lại micro nếu TTS gặp lỗi
        Future.delayed(Duration(milliseconds: 500), () {
          _startContinuousListening();
        });
      });

      print("TTS đã khởi tạo thành công");
    } catch (e) {
      print("Lỗi khởi tạo TTS: $e");
    }
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      print("TTS nói: $text");
      await _flutterTts.speak(text);
    }
  }

  void _updateStatus(String message) {
    setState(() {
      _statusMessage = message;
    });
  }

  Future<void> _captureAndAnalyze() async {
    if (!_isCameraInitialized || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Rung để thông báo bắt đầu chụp
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      }

      _updateStatus("Đang chụp và phân tích...");

      final XFile picture = await _cameraController!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(picture.path);

      // Nhận diện đối tượng
      final List<DetectedObject> objects = await _objectDetector.processImage(
        inputImage,
      );
      final List<ImageLabel> labels = await _imageLabeler.processImage(
        inputImage,
      );

      // Xử lý kết quả
      String result = _processResults(objects, labels);

      if (result.isNotEmpty) {
        _lastDetectedObjects = result;
        _updateStatus("Nhận diện hoàn tất");
        _updateStatus(result);

        // Rung để thông báo hoàn thành
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 200);
        }

        await _speak(result);
      } else {
        _updateStatus("Không nhận diện được vật thể nào rõ ràng");
        await _speak("Không nhận diện được vật thể nào rõ ràng");
      }
    } catch (e) {
      String errorMsg = "Lỗi khi phân tích hình ảnh: $e";
      _updateStatus(errorMsg);
      await _speak("Có lỗi xảy ra khi phân tích hình ảnh");
      print(errorMsg);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  String _processResults(
    List<DetectedObject> objects,
    List<ImageLabel> labels,
  ) {
    List<String> detectedItems = [];

    // Xử lý object detection
    for (DetectedObject object in objects) {
      for (Label label in object.labels) {
        if (label.confidence > 0.7) {
          String vietnameseLabel = TranslateObject.translateToVietnames(
            label.text,
          );
          detectedItems.add(
            "$vietnameseLabel với độ tin cậy ${(label.confidence * 100).toInt()}%",
          );
        }
      }
    }

    // Xử lý image labeling
    for (ImageLabel label in labels) {
      if (label.confidence > 0.7) {
        String vietnameseLabel = TranslateObject.translateToVietnames(label.label);
        if (!detectedItems.any((item) => item.contains(vietnameseLabel))) {
          detectedItems.add(
            "$vietnameseLabel với độ tin cậy ${(label.confidence * 100).toInt()}%",
          );
        }
      }
    }

    if (detectedItems.isEmpty) {
      return "";
    }

    String result = "Tôi nhận diện được: ${detectedItems.join(", ")}";
    return result;
  }

  Future<void> _speakUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      final name = user.email!.split('@').first;
      await _flutterTts.speak("Tài khoản của bạn là $name");
    } else {
      await _flutterTts.speak("Không tìm thấy thông tin người dùng");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kBottomNavigationBarHeight),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              'Nhận Diện Vật Thể',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            actions: [
              Semantics(
                label: "Thông tin tài khoản",
                child: IconButton(
                  icon: const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () async {
                    await _flutterTts.speak("Mở thông tin tài khoản");
                    _speakUserName();
                    _showUserInfoDialog(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Camera Preview
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: _isCameraInitialized
                    ? GestureDetector(
                        onTap: _captureAndAnalyze,
                        child: CameraPreview(_cameraController!),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 80.sp,
                              color: Colors.white,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Đang khởi tạo camera...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),

          // Status và Controls
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  // Status Message
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Row(
                      children: [
                        // Micro
                        Icon(
                          isVoiceListening ? Icons.mic : Icons.mic_off,
                          color: isVoiceListening ? Colors.green : Colors.red,
                          size: 30.sp,
                        ),

                        SizedBox(width: 8.w),

                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Setting Button
                      _buildControlButton(
                        icon: Icons.settings,
                        label: 'Cài đặt',
                        onPressed: () async {
                          await _speak("Mở cài đặt");
                          _showSettingsDialog();
                        },
                        color: Colors.orange,
                      ),

                      // Capture Button
                      _buildControlButton(
                        icon: _isProcessing
                            ? Icons.hourglass_empty
                            : Icons.camera_alt,
                        label: _isProcessing ? 'Đang xử lý' : 'Chụp',
                        onPressed: _isProcessing ? null : _captureAndAnalyze,
                        color: Colors.green,
                      ),

                      // Repeat Button
                      _buildControlButton(
                        icon: Icons.repeat,
                        label: 'Lặp lại',
                        onPressed: () {
                          if (_lastDetectedObjects.isNotEmpty) {
                            _speak(_lastDetectedObjects);
                          } else {
                            _speak("Chưa có thông tin nào để lặp lại");
                          }
                        },
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: MyDrawer(),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 70.w,
          height: 70.w,
          decoration: BoxDecoration(
            color: onPressed != null ? color : Colors.grey,
            borderRadius: BorderRadius.circular(35.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(35.r),
              onTap: onPressed,
              child: Icon(icon, color: Colors.white, size: 30.sp),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showSettingsDialog() {
    // Tạo bản sao tạm thời của các cài đặt
    double tempSpeechRate = _speechRate;
    double tempSpeechPitch = _speechPitch;
    bool tempContinuousMode = _continuousMode;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.settings, color: Color(0xFF0084FF), size: 24.sp),
              SizedBox(width: 8),
              Text(
                'Cài đặt',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tốc độ giọng nói
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tốc độ giọng nói',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF0084FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${tempSpeechRate.toStringAsFixed(1)}x',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Color(0xFF0084FF),
                          inactiveTrackColor: Color(
                            0xFF0084FF,
                          ).withOpacity(0.3),
                          thumbColor: Color(0xFF0084FF),
                          overlayColor: Color(0xFF0084FF).withOpacity(0.2),
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          trackHeight: 4,
                          valueIndicatorShape:
                              PaddleSliderValueIndicatorShape(),
                          valueIndicatorColor: Color(0xFF0084FF),
                          valueIndicatorTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                        child: Slider(
                          value: tempSpeechRate,
                          min: 0.1,
                          max: 1.0,
                          divisions: 18,
                          label: '${tempSpeechRate.toStringAsFixed(1)}x',
                          onChanged: (value) {
                            setDialogState(() {
                              tempSpeechRate = value;
                            });
                            _flutterTts.setSpeechRate(value);
                          },
                          onChangeEnd: (value) async {
                            // Nói hệ số khi thả tay ra
                            await _speak("Tốc độ ${value.toStringAsFixed(1)}");
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Chậm',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Nhanh',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Cao độ giọng nói
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cao độ giọng nói',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF0084FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tempSpeechPitch.toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Color(0xFF0084FF),
                          inactiveTrackColor: Color(
                            0xFF0084FF,
                          ).withOpacity(0.3),
                          thumbColor: Color(0xFF0084FF),
                          overlayColor: Color(0xFF0084FF).withOpacity(0.2),
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          trackHeight: 4,
                          valueIndicatorShape:
                              PaddleSliderValueIndicatorShape(),
                          valueIndicatorColor: Color(0xFF0084FF),
                          valueIndicatorTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                        child: Slider(
                          value: tempSpeechPitch,
                          min: 0.5,
                          max: 2.0,
                          divisions: 30,
                          label: tempSpeechPitch.toStringAsFixed(1),
                          onChanged: (value) {
                            setDialogState(() {
                              tempSpeechPitch = value;
                            });
                            _flutterTts.setPitch(value);
                          },
                          onChangeEnd: (value) async {
                            // Nói hệ số khi thả tay ra
                            await _speak("Cao độ ${value.toStringAsFixed(1)}");
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thấp',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Cao',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Nút test giọng nói
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await _speak(
                        "Đây là bản thử giọng nói với cài đặt hiện tại",
                      );
                    },
                    icon: Icon(Icons.volume_up, color: Color(0xFF0084FF)),
                    label: Text(
                      'Thử giọng nói',
                      style: TextStyle(
                        color: Color(0xFF0084FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF0084FF)),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await _speak("Hủy cài đặt");
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Hủy",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Lưu cài đặt vào state chính
                      setState(() {
                        _speechRate = tempSpeechRate;
                        _speechPitch = tempSpeechPitch;
                        _continuousMode = tempContinuousMode;
                      });

                      // Lưu vào SharedPreferences
                      await _saveSettings();

                      await _speak("Lưu cài đặt");
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0084FF),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Lưu",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUserInfoDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Get current user's userType from Firestore
    FirebaseFirestore.instance
        .collection('Users')
        .doc(user?.uid)
        .get()
        .then((doc) {
          String userType = "Không xác định";
          if (doc.exists) {
            userType = doc.data()?['userType'] ?? "Không xác định";
          }

          showDialog(
            context: context,
            builder: (_) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? Icon(Icons.person, size: 40)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.email?.split('@').first ?? "Không có tên",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? "Không có email",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    // Display userType with styling
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: userType == "blind"
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: userType == "blind"
                              ? Colors.blue
                              : Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            userType == "blind"
                                ? Icons.visibility_off
                                : Icons.person,
                            size: 16,
                            color: userType == "blind"
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            userType == "blind"
                                ? "Khiếm thị"
                                : userType == "normal"
                                ? "Người bình thường"
                                : "Không xác định",
                            style: TextStyle(
                              fontSize: 14,
                              color: userType == "blind"
                                  ? Colors.blue
                                  : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _speak("Đóng thông tin tài khoản");
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0084FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Đóng",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        })
        .catchError((error) {
          // Handle error case
          showDialog(
            context: context,
            builder: (_) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Icon(Icons.person, size: 40)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.email?.split('@').first ?? "Không có tên",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? "Không có email",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error, size: 16, color: Colors.red),
                          SizedBox(width: 4),
                          Text(
                            "Không thể tải thông tin",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0084FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Đóng",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  // Dọn dẹp tài nguyên
  @override
  void dispose() {
    _cameraController?.dispose();
    _objectDetector.close();
    _imageLabeler.close();
    _flutterTts.stop();
    super.dispose();
  }
}
