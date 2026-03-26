import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/laptop.dart';
import 'package:flutter/services.dart'; // for rootBundle

class LaptopProvider extends ChangeNotifier {
  List<Laptop> _laptops = [];
  List<Laptop> get laptops => _laptops;

  bool _isInitialized = false;
  static const String _storageKey = 'laptops_data';
  static const String _passwordKey = 'seller_password';

  Future<void> loadLaptops() async {
    print('🔄 loadLaptops() called');
    await _loadLaptops();
  }

  LaptopProvider() {
    print('🏭 LaptopProvider constructor');
    _initialize();
  }

  Future<void> _initialize() async {
    if (!_isInitialized) {
      print('🔧 Initializing provider...');
      await _loadLaptops();
      _isInitialized = true;
    }
  }

  Future<String> getSellerPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey) ?? 'admin123';
  }

  Future<void> setSellerPassword(String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, newPassword);
    print('🔑 Password updated');
  }

Future<void> _loadLaptops() async {
  print('📂 _loadLaptops() started');
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? laptopsJson = prefs.getString(_storageKey);

    if (laptopsJson != null && laptopsJson.isNotEmpty) {
      print('📦 Found saved data, length: ${laptopsJson.length}');
      final List<dynamic> jsonList = json.decode(laptopsJson);
      _laptops = jsonList.map((json) => Laptop.fromJson(json)).toList();
      print('✅ Loaded ${_laptops.length} laptops from storage');
      for (var laptop in _laptops) {
        print('   - ${laptop.brand} ${laptop.model}, images: ${laptop.images.length}');
      }
    } else {
      print('📝 No saved data – loading from JSON file');
      // Load from assets/laptops.json
      final String jsonString = await rootBundle.loadString('assets/laptops.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _laptops = jsonList.map((json) => Laptop.fromJson(json)).toList();
      print('✅ Loaded ${_laptops.length} laptops from JSON file');
      // Save to SharedPreferences so it persists
      await _saveLaptops();
      print('💾 Sample data saved to storage');
    }
  } catch (e, stack) {
    print('❌ Error loading laptops: $e');
    print(stack);
    // Fallback: if all else fails, use hardcoded sample data (optional)
    _initializeSampleData();
    await _saveLaptops();
  }
  notifyListeners();
}

  Future<void> _saveLaptops() async {
    print('💾 _saveLaptops() started');
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList =
          _laptops.map((laptop) => laptop.toJson()).toList();
      final String encoded = json.encode(jsonList);
      print('   Data size: ${encoded.length} characters');
      await prefs.setString(_storageKey, encoded);
      print('💾 Saved ${_laptops.length} laptops to storage');
    } catch (e, stack) {
      print('❌ Error saving laptops: $e');
      print(stack);
    }
  }

  void _initializeSampleData() {
    _laptops = [
      Laptop(
        id: '1',
        brand: 'Dell',
        model: 'Inspiron 5300',
        processor: 'Intel Core i5-8265U',
        ram: '16GB DDR4',
        storage: '256GB NVMe SSD',
        graphics: 'Integrated',
        screenSize: 14.0,
        displayType: 'HD',
        price: 20000,
        stock: 1,
        imageUrl: 'assets/images/Dell-5300-1.jpg',
        thumbnailUrl: 'assets/thumbnails/Dell-5300-1.jpg',
        images: [
          'assets/images/Dell-5300-2.jpg',
          'assets/images/Dell-5300-3.jpg',
          'assets/images/Dell-5300-4.jpg',
        ],
        description: 'Dell Inspiron 5300 – powerful i5, 16GB RAM, 256GB NVMe SSD',
        isAsset: true,
      ),
      Laptop(
        id: '2',
        brand: 'Lenovo',
        model: 'V130-15',
        processor: 'Intel Core i3-7020U',
        ram: '8GB DDR4',
        storage: '480GB SATA SSD',
        graphics: 'Integrated',
        screenSize: 15.6,
        displayType: 'HD',
        price: 18500,
        stock: 1,
        imageUrl: 'assets/images/Lenovo-V130-1.jpg',
        thumbnailUrl: 'assets/thumbnails/Lenovo-V130-1.jpg',
        images: [
          'assets/images/Lenovo-V130-2.jpg',
          'assets/images/Lenovo-V130-3.jpg',
          'assets/images/Lenovo-V130-4.jpg',
        ],
        description: 'Second‑hand Lenovo V130 – powerful i3, 8GB RAM',
        isAsset: true,
      ),
      Laptop(
        id: '3',
        brand: 'Lenovo',
        model: 'B41 (4GB)',
        processor: 'AMD A6-7310',
        ram: '4GB DDR3',
        storage: '120GB SATA SSD',
        graphics: 'Integrated',
        screenSize: 14.0,
        displayType: 'HD',
        price: 11500,
        stock: 1,
        imageUrl: 'assets/images/b41-1.jpg',
        thumbnailUrl: 'assets/thumbnails/b41-1.jpg',
        images: [
          'assets/images/b41-2.jpg',
          'assets/images/b41-3.jpg',
          'assets/images/b41-4.jpg',
        ],
        description: 'Second‑hand Lenovo B41 – budget friendly',
        isAsset: true,
      ),
      // B41 (8GB) removed – sold out
      Laptop(
        id: '5',
        brand: 'Lenovo',
        model: 'IP110',
        processor: 'Intel Pentium N3710',
        ram: '4GB DDR3',
        storage: '120GB',
        graphics: 'Integrated',
        screenSize: 15.6,
        displayType: 'HD',
        price: 12500,
        stock: 1,
        imageUrl: 'assets/images/IP-110-1.jpg',
        thumbnailUrl: 'assets/thumbnails/IP-110-1.jpg',
        images: [
          'assets/images/IP-110-2.jpg',
          'assets/images/IP-110-3.jpg',
          'assets/images/IP-110-4.jpg',
        ],
        description: 'Second‑hand Lenovo IP110 – reliable daily driver',
        isAsset: true,
      ),
      // Asus X540Y
      Laptop(
        id: '6',
        brand: 'Asus',
        model: 'X540Y',
        processor: 'AMD E2-6110 Quad Core',
        ram: '4GB DDR3',
        storage: '128GB SATA SSD',
        graphics: 'AMD R2 Onboard',
        screenSize: 15.6,
        displayType: 'HD',
        price: 12000,
        stock: 1,
        imageUrl: 'assets/images/Asus-X540Y-1.jpg',
        thumbnailUrl: 'assets/thumbnails/Asus-X540Y-1.jpg',
        images: [
          'assets/images/Asus-X540Y-2.jpg',
          'assets/images/Asus-X540Y-3.jpg',
        ],
        description: 'Asus X540Y – reliable daily driver with AMD E2 processor',
        isAsset: true,
      ),
      // Apple MacBook Air Mid 2012
      Laptop(
        id: '7',
        brand: 'Apple',
        model: 'MacBook Air Mid 2012',
        processor: '1.8 GHZ Dual-Core Intel Core i5',
        ram: '4GB 1600 MHz DDR3',
        storage: '128GB SSD',
        graphics: 'Intel HD Graphics 4000',
        screenSize: 13.0,
        displayType: 'HD+',
        price: 25000,
        stock: 1,
        imageUrl: 'assets/images/Mac-2012-1.jpg',
        thumbnailUrl: 'assets/thumbnails/Mac-2012-1.jpg',
        images: [
          'assets/images/Mac-2012-2.jpg',
          'assets/images/Mac-2012-3.jpg',
          'assets/images/Mac-2012-4.jpg',
        ],
        description: 'Apple MacBook Air Mid 2012 – classic, lightweight, reliable',
        isAsset: true,
      ),
      // Lenovo E41
      Laptop(
        id: '8',
        brand: 'Lenovo',
        model: 'E41',
        processor: 'AMD A6 7310',
        ram: '4GB DDR3',
        storage: '128GB SATA SSD',
        graphics: 'AMD R4 Onboard',
        screenSize: 14.6,
        displayType: 'HD',
        price: 12501,
        stock: 1,
        imageUrl: 'assets/images/Lenovo-E41-1.jpg',
        thumbnailUrl: 'assets/thumbnails/Lenovo-E41-1.jpg',
        images: [
          'assets/images/Lenovo-E41-2.jpg',
          'assets/images/Lenovo-E41-3.jpg',
          'assets/images/Lenovo-E41-4.jpg',
        ],
        description: 'Lenovo E41 – efficient AMD A6, 4GB RAM, 128GB SSD',
        isAsset: true,
      ),
    ];
  }

  Future<void> addLaptop(Laptop laptop) async {
    _laptops.add(laptop);
    await _saveLaptops();
    notifyListeners();
  }

  Future<void> updateLaptop(Laptop updatedLaptop) async {
    final index = _laptops.indexWhere((l) => l.id == updatedLaptop.id);
    if (index != -1) {
      _laptops[index] = updatedLaptop;
      await _saveLaptops();
      notifyListeners();
    }
  }

  Future<void> deleteLaptop(String id) async {
    _laptops.removeWhere((laptop) => laptop.id == id);
    await _saveLaptops();
    notifyListeners();
  }

  List<Laptop> searchLaptops(String query) {
    if (query.isEmpty) return _laptops;
    return _laptops.where((laptop) {
      return laptop.brand.toLowerCase().contains(query.toLowerCase()) ||
          laptop.model.toLowerCase().contains(query.toLowerCase()) ||
          laptop.processor.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  int get totalLaptops => _laptops.length;
  int get totalStock => _laptops.fold(0, (sum, laptop) => sum + laptop.stock);
  double get totalValue => _laptops.fold(0.0,
      (sum, laptop) => sum + (laptop.price * laptop.stock));

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;
}