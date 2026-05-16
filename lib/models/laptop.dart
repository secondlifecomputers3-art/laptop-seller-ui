class Laptop {
  final String id;
  String brand;
  String model;
  String processor;
  String ram;
  String storage;
  String graphics;
  double screenSize;
  String displayType;
  double price;
  int stock;
  String imageUrl;           // full‑size main image
  String thumbnailUrl;       // small version for lists
  List<String> images;       // full‑size extra images
  String description;
  bool isAsset;

  Laptop({
    required this.id,
    required this.brand,
    required this.model,
    required this.processor,
    required this.ram,
    required this.storage,
    required this.graphics,
    required this.screenSize,
    required this.displayType,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.thumbnailUrl,
    this.images = const [],
    this.description = '',
    this.isAsset = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'processor': processor,
      'ram': ram,
      'storage': storage,
      'graphics': graphics,
      'screenSize': screenSize,
      'displayType': displayType,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'images': images,
      'description': description,
      'isAsset': isAsset,
    };
  }

  factory Laptop.fromJson(Map<String, dynamic> json) {
    double toDoubleSafe(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.parse(value);
      return 0.0;
    }

    int toIntSafe(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.parse(value);
      return 0;
    }

    bool toBoolSafe(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    return Laptop(
      id: json['id']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      processor: json['processor']?.toString() ?? '',
      ram: json['ram']?.toString() ?? '',
      storage: json['storage']?.toString() ?? '',
      graphics: json['graphics']?.toString() ?? '',
      screenSize: toDoubleSafe(json['screenSize']),
      displayType: json['displayType']?.toString() ?? '',
      price: toDoubleSafe(json['price']),
      stock: toIntSafe(json['stock']),
      imageUrl: json['imageUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      description: json['description']?.toString() ?? '',
      isAsset: toBoolSafe(json['isAsset']),
    );
  }

  Laptop copyWith({
    String? id,
    String? brand,
    String? model,
    String? processor,
    String? ram,
    String? storage,
    String? graphics,
    double? screenSize,
    String? displayType,
    double? price,
    int? stock,
    String? imageUrl,
    String? thumbnailUrl,
    List<String>? images,
    String? description,
    bool? isAsset,
  }) {
    return Laptop(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      processor: processor ?? this.processor,
      ram: ram ?? this.ram,
      storage: storage ?? this.storage,
      graphics: graphics ?? this.graphics,
      screenSize: screenSize ?? this.screenSize,
      displayType: displayType ?? this.displayType,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      images: images ?? this.images,
      description: description ?? this.description,
      isAsset: isAsset ?? this.isAsset,
    );
  }
}