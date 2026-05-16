import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/laptop.dart';

class LaptopProvider extends ChangeNotifier {
  List<Laptop> _laptops = [];
  List<Laptop> get laptops => _laptops;

  LaptopProvider() {
    _loadLaptopsFromJsonOnly();
  }

  // Only load from JSON - NO HARDCODED DATA
  Future<void> _loadLaptopsFromJsonOnly() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/laptops.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _laptops = jsonList.map((json) => Laptop.fromJson(json)).toList();
      print('✅ Loaded ${_laptops.length} laptops from laptops.json');
    } catch (e) {
      print('❌ Error loading laptops.json: $e');
      _laptops = []; // Empty list if JSON fails
    }
    notifyListeners();
  }

  // Force reload from JSON
  Future<void> reloadFromJson() async {
    await _loadLaptopsFromJsonOnly();
  }

  void addLaptop(Laptop laptop) {
    _laptops.add(laptop);
    notifyListeners();
  }

  void updateLaptop(Laptop updatedLaptop) {
    final index = _laptops.indexWhere((l) => l.id == updatedLaptop.id);
    if (index != -1) {
      _laptops[index] = updatedLaptop;
      notifyListeners();
    }
  }

  void deleteLaptop(String id) {
    _laptops.removeWhere((laptop) => laptop.id == id);
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
  double get totalValue => _laptops.fold(0.0, (sum, laptop) => sum + (laptop.price * laptop.stock));
}