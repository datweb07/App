import 'package:flutter/material.dart';

class TranslateObject extends StatefulWidget {
  const TranslateObject({super.key});

  static translateToVietnames(String englishLabel) {
    _TranslateObjectState._translateToVietnamese(englishLabel);
  }

  @override
  _TranslateObjectState createState() => _TranslateObjectState();
}

class _TranslateObjectState extends State<TranslateObject> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  static String _translateToVietnamese(String englishLabel) {
    // Dictionary đơn giản để dịch một số từ phổ biến
    Map<String, String> translations = {
      'person': 'người',
      'car': 'xe hơi',
      'dog': 'chó',
      'cat': 'mèo',
      'chair': 'ghế',
      'table': 'bàn',
      'book': 'sách',
      'phone': 'điện thoại',
      'cup': 'cốc',
      'bottle': 'chai',
      'food': 'thức ăn',
      'plant': 'cây',
      'flower': 'hoa',
      'tree': 'cây',
      'building': 'tòa nhà',
      'door': 'cửa',
      'window': 'cửa sổ',
      'laptop': 'máy tính xách tay',
      'keyboard': 'bàn phím',
      'mouse': 'chuột máy tính',
      'bag': 'túi',
      'shoe': 'giày',
      'clock': 'đồng hồ',
      'television': 'tivi',
      'bed': 'giường',
      'sofa': 'ghế sofa',
      'hand': 'tay',
      'nail': 'móng',
      'room': 'phòng',
      'paper': 'giấy',
      'jacket': 'áo',
      'handbag': 'túi xách tay',
      'aviation': 'hàng không',

      'people': 'mọi người',
      'man': 'nam giới',
      'woman': 'nữ giới',
      'child': 'trẻ em',
      'baby': 'em bé',
      'boy': 'cậu bé',
      'girl': 'cô bé',
      'adult': 'người lớn',
      'elderly': 'người cao tuổi',
      'face': 'khuôn mặt',
      'head': 'đầu',
      'hair': 'tóc',
      'eye': 'mắt',
      'nose': 'mũi',
      'mouth': 'miệng',
      'ear': 'tai',
      'finger': 'ngón tay',
      'arm': 'cánh tay',
      'leg': 'chân',
      'foot': 'bàn chân',
      'body': 'cơ thể',

      'vehicle': 'phương tiện',
      'truck': 'xe tải',
      'bus': 'xe buýt',
      'motorcycle': 'xe máy',
      'bicycle': 'xe đạp',
      'taxi': 'taxi',
      'ambulance': 'xe cứu thương',
      'fire truck': 'xe cứu hỏa',
      'police car': 'xe cảnh sát',
      'train': 'tàu hỏa',
      'airplane': 'máy bay',
      'boat': 'thuyền',
      'ship': 'tàu thủy',
      'wheel': 'bánh xe',
      'tire': 'lốp xe',
      'bumper': 'cản xe',
      'headlight': 'đèn pha',
      'traffic light': 'đèn giao thông',
      'stop sign': 'biển báo dừng',
      'road': 'đường',
      'street': 'phố',
      'sidewalk': 'vỉa hè',
      'crosswalk': 'vạch sang đường',
      'bridge': 'cầu',

      'animal': 'động vật',
      'bird': 'chim',
      'fish': 'cá',
      'horse': 'ngựa',
      'cow': 'bò',
      'pig': 'heo',
      'chicken': 'gà',
      'duck': 'vịt',
      'rabbit': 'thỏ',
      'elephant': 'voi',
      'tiger': 'hổ',
      'lion': 'sư tử',
      'bear': 'gấu',
      'monkey': 'khỉ',
      'snake': 'rắn',
      'frog': 'ếch',
      'butterfly': 'bướm',
      'bee': 'ong',
      'spider': 'nhện',
      'insect': 'côn trùng',

      'kitchen': 'nhà bếp',
      'stove': 'bếp nấu',
      'oven': 'lò nướng',
      'refrigerator': 'tủ lạnh',
      'microwave': 'lò vi sóng',
      'sink': 'bồn rửa',
      'faucet': 'vòi nước',
      'mug': 'cốc có quai',
      'glass': 'ly thủy tinh',
      'bowl': 'bát',
      'plate': 'đĩa',
      'spoon': 'thìa',
      'fork': 'nĩa',
      'knife': 'dao',
      'chopsticks': 'đũa',
      'pot': 'nồi',
      'pan': 'chảo',
      'kettle': 'ấm đun nước',
      'toaster': 'máy nướng bánh mì',
      'blender': 'máy xay sinh tố',

      'drink': 'đồ uống',
      'water': 'nước',
      'tea': 'trà',
      'coffee': 'cà phê',
      'milk': 'sữa',
      'juice': 'nước ép',
      'bread': 'bánh mì',
      'rice': 'cơm',
      'noodle': 'mì',
      'soup': 'canh',
      'meat': 'thịt',
      'beef': 'thịt bò',
      'pork': 'thịt heo',
      'egg': 'trứng',
      'vegetable': 'rau',
      'fruit': 'trái cây',
      'apple': 'táo',
      'banana': 'chuối',
      'orange': 'cam',
      'lemon': 'chanh',
      'tomato': 'cà chua',
      'potato': 'khoai tây',
      'onion': 'hành tây',
      'garlic': 'tỏi',
      'carrot': 'cà rốt',
      'cabbage': 'bắp cải',
      'lettuce': 'xà lách',
      'cucumber': 'dưa chuột',
      'pepper': 'ớt',
      'salt': 'muối',
      'sugar': 'đường',
      'oil': 'dầu ăn',
      'sauce': 'nước sốt',
      'cake': 'bánh ngọt',
      'cookie': 'bánh quy',
      'candy': 'kẹo',
      'chocolate': 'sô cô la',
      'ice cream': 'kem',

      'furniture': 'đồ nội thất',
      'desk': 'bàn làm việc',
      'couch': 'ghế dài',
      'armchair': 'ghế bành',
      'bookshelf': 'kệ sách',
      'cabinet': 'tủ',
      'drawer': 'ngăn kéo',
      'wardrobe': 'tủ quần áo',
      'mirror': 'gương',
      'lamp': 'đèn',
      'light': 'ánh sáng',
      'bulb': 'bóng đèn',
      'fan': 'quạt',
      'air conditioner': 'điều hòa',
      'heater': 'máy sưởi',
      'curtain': 'rèm cửa',
      'pillow': 'gối',
      'blanket': 'chăn',
      'sheet': 'ga trải giường',
      'towel': 'khăn',
      'soap': 'xà phòng',
      'shampoo': 'dầu gội',
      'toothbrush': 'bàn chải đánh răng',
      'toothpaste': 'kem đánh răng',
      'toilet paper': 'giấy vệ sinh',
      'tissue': 'khăn giấy',
      'vacuum cleaner': 'máy hút bụi',
      'broom': 'chổi',
      'mop': 'cây lau nhà',
      'bucket': 'thùng nước',
      'trash can': 'thùng rác',
      'garbage': 'rác',
      'recycling bin': 'thùng rác tái chế',

      'smartphone': 'điện thoại thông minh',
      'tablet': 'máy tính bảng',
      'computer': 'máy tính',
      'monitor': 'màn hình',
      'speaker': 'loa',
      'headphones': 'tai nghe',
      'earphones': 'tai nghe nhỏ',
      'microphone': 'micro',
      'camera': 'máy ảnh',
      'tv': 'tivi',
      'remote control': 'điều khiển từ xa',
      'radio': 'đài radio',
      'cd player': 'máy nghe CD',
      'dvd player': 'máy phát DVD',
      'game console': 'máy chơi game',
      'charger': 'sạc',
      'cable': 'dây cáp',
      'battery': 'pin',
      'power bank': 'pin dự phòng',
      'usb': 'USB',
      'hard drive': 'ổ cứng',
      'flash drive': 'USB',
      'printer': 'máy in',
      'scanner': 'máy quét',
      'router': 'bộ phát wifi',
      'modem': 'modem',

      'clothes': 'quần áo',
      'clothing': 'trang phục',
      'shirt': 'áo sơ mi',
      't-shirt': 'áo phông',
      'coat': 'áo dài',
      'sweater': 'áo len',
      'hoodie': 'áo hoodie',
      'dress': 'váy',
      'skirt': 'chân váy',
      'pants': 'quần dài',
      'trousers': 'quần',
      'jeans': 'quần jean',
      'shorts': 'quần short',
      'underwear': 'đồ lót',
      'socks': 'tất',
      'shoes': 'giày',
      'sneakers': 'giày thể thao',
      'boots': 'ủng',
      'sandals': 'dép',
      'slippers': 'dép lê',
      'hat': 'mũ',
      'cap': 'nón',
      'helmet': 'mũ bảo hiểm',
      'glasses': 'kính',
      'sunglasses': 'kính râm',
      'watch': 'đồng hồ đeo tay',
      'jewelry': 'trang sức',
      'necklace': 'vòng cổ',
      'bracelet': 'vòng tay',
      'ring': 'nhẫn',
      'earrings': 'khuyên tai',
      'belt': 'thắt lưng',
      'tie': 'cà vạt',
      'scarf': 'khăn quàng',
      'gloves': 'găng tay',
      'purse': 'ví',
      'wallet': 'ví tiền',
      'backpack': 'ba lô',
      'suitcase': 'vali',
      'luggage': 'hành lý',

      'tool': 'công cụ',
      'hammer': 'búa',
      'screwdriver': 'tuốc nơ vít',
      'wrench': 'cờ lê',
      'pliers': 'kìm',
      'scissors': 'kéo',
      'screw': 'vít',
      'drill': 'máy khoan',
      'saw': 'cưa',
      'ladder': 'thang',
      'rope': 'dây thừng',
      'tape': 'băng keo',
      'glue': 'keo',
      'measuring tape': 'thước dây',
      'ruler': 'thước kẻ',
      'level': 'thước thủy',
      'flashlight': 'đèn pin',
      'candle': 'nến',
      'matches': 'diêm',
      'lighter': 'bật lửa',
      'fire extinguisher': 'bình chữa cháy',
      'first aid kit': 'hộp sơ cứu',
      'bandage': 'băng',
      'medicine': 'thuốc',
      'pill': 'viên thuốc',
      'thermometer': 'nhiệt kế',
    };

    return translations[englishLabel.toLowerCase()] ?? englishLabel;
  }
}
