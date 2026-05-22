import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/laptop.dart';

class LaptopProvider extends ChangeNotifier {
  List<Laptop> _laptops = [];
  List<Laptop> get laptops => _laptops;

  LaptopProvider() {
    _loadLaptopsFromJson();
  }

  Future<void> _loadLaptopsFromJson() async {
    try {
      print('🔄 Loading laptops from JSON...');
      
      // Load JSON from assets
      final String jsonString = await rootBundle.loadString('assets/laptops.json');
      print('📄 Raw JSON length: ${jsonString.length} characters');
      
      // Parse JSON
      final List<dynamic> jsonList = json.decode(jsonString);
      print('📊 Found ${jsonList.length} items in JSON');
      
      // Print each laptop found
      for (var i = 0; i < jsonList.length; i++) {
        print('   📱 Item ${i+1}: ${jsonList[i]['brand']} ${jsonList[i]['model']} (ID: ${jsonList[i]['id']})');
      }
      
      // Convert JSON to Laptop objects
      _laptops = jsonList.map((json) => Laptop.fromJson(json)).toList();
      
      print('✅ Successfully loaded ${_laptops.length} laptops');
      
    } catch (e) {
      print('❌ Error loading laptops.json: $e');
      _laptops = [];
    }
    notifyListeners();
  }

  // Force reload from JSON
  Future<void> reloadLaptops() async {
    print('🔄 Manual reload triggered');
    await _loadLaptopsFromJson();
  }

  void addLaptop(Laptop laptop) {
    print('➕ Adding laptop: ${laptop.brand} ${laptop.model}');
    _laptops.add(laptop);
    notifyListeners();
  }

  void updateLaptop(Laptop updatedLaptop) {
    print('✏️ Updating laptop: ${updatedLaptop.brand} ${updatedLaptop.model}');
    final index = _laptops.indexWhere((l) => l.id == updatedLaptop.id);
    if (index != -1) {
      _laptops[index] = updatedLaptop;
      notifyListeners();
    }
  }

  void deleteLaptop(String id) {
    print('🗑️ Deleting laptop with ID: $id');
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