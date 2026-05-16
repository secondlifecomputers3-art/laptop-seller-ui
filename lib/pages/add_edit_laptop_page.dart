import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'dart:convert';
import '../models/laptop.dart';
import '../providers/laptop_provider.dart';

class AddEditLaptopPage extends StatefulWidget {
  final Laptop? laptop;
  const AddEditLaptopPage({super.key, this.laptop});

  @override
  State<AddEditLaptopPage> createState() => _AddEditLaptopPageState();
}

class _AddEditLaptopPageState extends State<AddEditLaptopPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _processorController;
  late TextEditingController _ramController;
  late TextEditingController _storageController;
  late TextEditingController _graphicsController;
  late TextEditingController _screenSizeController;
  late TextEditingController _displayController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descriptionController;
  List<TextEditingController> _extraImageControllers = [];

  bool _isLoading = false;
  bool _isAsset = true;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.laptop?.brand ?? '');
    _modelController = TextEditingController(text: widget.laptop?.model ?? '');
    _processorController = TextEditingController(text: widget.laptop?.processor ?? '');
    _ramController = TextEditingController(text: widget.laptop?.ram ?? '');
    _storageController = TextEditingController(text: widget.laptop?.storage ?? '');
    _graphicsController = TextEditingController(text: widget.laptop?.graphics ?? '');
    _screenSizeController = TextEditingController(text: widget.laptop?.screenSize.toString() ?? '');
    _displayController = TextEditingController(text: widget.laptop?.displayType ?? '');
    _priceController = TextEditingController(text: widget.laptop?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.laptop?.stock.toString() ?? '');
    _imageUrlController = TextEditingController(
      text: widget.laptop?.imageUrl ?? 'assets/images/lenovo_b41.jpg',
    );
    _descriptionController = TextEditingController(text: widget.laptop?.description ?? '');
    _isAsset = widget.laptop?.isAsset ?? true;

    if (widget.laptop != null && widget.laptop!.images.isNotEmpty) {
      for (var url in widget.laptop!.images) {
        _extraImageControllers.add(TextEditingController(text: url));
      }
    } else {
      _extraImageControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _processorController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _graphicsController.dispose();
    _screenSizeController.dispose();
    _displayController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    for (var c in _extraImageControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addImageField() {
    setState(() {
      _extraImageControllers.add(TextEditingController());
    });
  }

  void _removeImageField(int index) {
    setState(() {
      _extraImageControllers[index].dispose();
      _extraImageControllers.removeAt(index);
    });
  }

  Future<void> _pickMainImage() async {
    try {
      final pickedImage = await ImagePickerWeb.getImageAsBytes();
      if (pickedImage != null) {
        String base64Image = base64Encode(pickedImage);
        String dataUrl = 'data:image/jpeg;base64,$base64Image';
        setState(() {
          _imageUrlController.text = dataUrl;
          _isAsset = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _pickExtraImage(int index) async {
    try {
      final pickedImage = await ImagePickerWeb.getImageAsBytes();
      if (pickedImage != null) {
        String base64Image = base64Encode(pickedImage);
        String dataUrl = 'data:image/jpeg;base64,$base64Image';
        setState(() {
          _extraImageControllers[index].text = dataUrl;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _saveLaptop() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final provider = Provider.of<LaptopProvider>(context, listen: false);
        List<String> extraImages = _extraImageControllers
            .map((c) => c.text.trim())
            .where((url) => url.isNotEmpty)
            .toList();

        final laptop = Laptop(
          id: widget.laptop?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          processor: _processorController.text.trim(),
          ram: _ramController.text.trim(),
          storage: _storageController.text.trim(),
          graphics: _graphicsController.text.trim(),
          screenSize: double.parse(_screenSizeController.text.trim()),
          displayType: _displayController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          stock: int.parse(_stockController.text.trim()),
          imageUrl: _imageUrlController.text.trim(),
          // Use the same URL for thumbnail (can be improved later)
          thumbnailUrl: _imageUrlController.text.trim(),
          images: extraImages,
          description: _descriptionController.text.trim(),
          isAsset: _isAsset,
        );

        if (widget.laptop == null) {
          await provider.addLaptop(laptop);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Added'), backgroundColor: Colors.green));
        } else {
          await provider.updateLaptop(laptop);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Updated'), backgroundColor: Colors.blue));
        }
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final isEditing = widget.laptop != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Laptop' : 'Add New Laptop'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(isDesktop ? 20 : 12),
                  children: [
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: EdgeInsets.all(isDesktop ? 20 : 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _imageUrlController,
                                    decoration: InputDecoration(
                                      labelText: 'Main Image URL or Data URL',
                                      prefixIcon: const Icon(Icons.image, color: Color(0xFF667eea)),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    validator: (value) => value!.isEmpty ? 'Main image required' : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.upload_file),
                                  onPressed: _pickMainImage,
                                  tooltip: 'Upload Image',
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            Text('Additional Images', style: TextStyle(fontSize: isDesktop ? 18 : 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),

                            ..._extraImageControllers.asMap().entries.map((entry) {
                              int idx = entry.key;
                              var controller = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                          labelText: 'Extra Image URL ${idx + 1}',
                                          prefixIcon: const Icon(Icons.link, color: Color(0xFF667eea)),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.upload_file),
                                      onPressed: () => _pickExtraImage(idx),
                                    ),
                                    if (_extraImageControllers.length > 1)
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                                        onPressed: () => _removeImageField(idx),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),

                            Center(
                              child: TextButton.icon(
                                onPressed: _addImageField,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: const Text('Add another image'),
                              ),
                            ),

                            const SizedBox(height: 20),
                            const Divider(),

                            Row(
                              children: [
                                const Text('Use local assets (for pre‑loaded images):'),
                                Switch(
                                  value: _isAsset,
                                  onChanged: (val) => setState(() => _isAsset = val),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            Text('Product Details', style: TextStyle(fontSize: isDesktop ? 18 : 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),

                            _buildTextField(_brandController, 'Brand', Icons.business),
                            _buildTextField(_modelController, 'Model', Icons.computer),
                            _buildTextField(_processorController, 'Processor', Icons.memory),
                            Row(children: [Expanded(child: _buildTextField(_ramController, 'RAM', Icons.memory)), const SizedBox(width: 10), Expanded(child: _buildTextField(_storageController, 'Storage', Icons.storage))]),
                            _buildTextField(_graphicsController, 'Graphics', Icons.games),
                            Row(children: [Expanded(child: _buildTextField(_screenSizeController, 'Screen Size', Icons.aspect_ratio, isNumber: true)), const SizedBox(width: 10), Expanded(child: _buildTextField(_displayController, 'Display Type', Icons.screen_lock_portrait))]),
                            Row(children: [Expanded(child: _buildTextField(_priceController, 'Price (₹)', Icons.attach_money, isNumber: true)), const SizedBox(width: 10), Expanded(child: _buildTextField(_stockController, 'Stock', Icons.inventory, isNumber: true))]),
                            _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 3),

                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(foregroundColor: Colors.grey[700]), child: const Text('Cancel'))),
                                const SizedBox(width: 10),
                                Expanded(child: ElevatedButton(onPressed: _saveLaptop, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF667eea)), child: Text(isEditing ? 'Update' : 'Add'))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.trim().isEmpty) return '$label is required';
          if (isNumber && double.tryParse(value) == null) return 'Enter a valid number';
          return null;
        },
      ),
    );
  }
}