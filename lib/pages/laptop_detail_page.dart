import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/laptop.dart';

class LaptopDetailPage extends StatefulWidget {
  final Laptop laptop;
  const LaptopDetailPage({super.key, required this.laptop});

  @override
  State<LaptopDetailPage> createState() => _LaptopDetailPageState();
}

class _LaptopDetailPageState extends State<LaptopDetailPage> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  final String phoneNumber = "+918055006894";

  String _formatINR(double price) {
    String priceStr = price.round().toString();
    int length = priceStr.length;
    if (length > 3) {
      String lastThree = priceStr.substring(length - 3);
      String rest = priceStr.substring(0, length - 3);
      String restFormatted = '';
      for (int i = 0; i < rest.length; i++) {
        if (i > 0 && (rest.length - i) % 2 == 0) restFormatted += ',';
        restFormatted += rest[i];
      }
      return '₹$restFormatted,$lastThree';
    } else {
      return '₹$priceStr';
    }
  }

  List<String> _getAllImages() {
    return [widget.laptop.imageUrl, ...widget.laptop.images];
  }

  ImageProvider _getImageProvider(String url, bool isAsset) {
    if (url.startsWith('data:image')) {
      final base64String = url.split(',').last;
      return MemoryImage(base64Decode(base64String));
    } else if (isAsset) {
      return AssetImage(url);
    } else {
      return NetworkImage(url);
    }
  }

  Future<void> _launchWhatsApp() async {
    final message = '''
I'm interested in this laptop:
*${widget.laptop.brand} ${widget.laptop.model}*
- Processor: ${widget.laptop.processor}
- RAM: ${widget.laptop.ram}
- Storage: ${widget.laptop.storage}
- Graphics: ${widget.laptop.graphics}
- Screen: ${widget.laptop.screenSize}" ${widget.laptop.displayType}
- Price: ${_formatINR(widget.laptop.price)}
- Stock: ${widget.laptop.stock} available
''';
    final encodedMessage = Uri.encodeComponent(message);
    final url = 'https://wa.me/$phoneNumber?text=$encodedMessage';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp')),
      );
    }
  }

  Future<void> _launchPhoneDialer() async {
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open dialer')),
      );
    }
  }

  void _openFullScreenImage(int initialIndex) {
    final allImages = _getAllImages();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              '${initialIndex + 1} / ${allImages.length}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: _getImageProvider(allImages[index], widget.laptop.isAsset),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            itemCount: allImages.length,
            pageController: PageController(initialPage: initialIndex),
            onPageChanged: (index) => setState(() {}),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final allImages = _getAllImages();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.laptop.brand} ${widget.laptop.model}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 30 : 16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 30 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image carousel with tappable images
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: isDesktop ? 300 : 200,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: allImages.length,
                              onPageChanged: (index) => setState(() => _currentImageIndex = index),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => _openFullScreenImage(index),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      color: Colors.grey[200],
                                      child: Image(
                                        image: _getImageProvider(allImages[index], widget.laptop.isAsset),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (allImages.length > 1) ...[
                            Positioned(
                              left: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                                  onPressed: () {
                                    _pageController.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (allImages.length > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(allImages.length, (index) {
                              return GestureDetector(
                                onTap: () => _openFullScreenImage(index),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index ? const Color(0xFF667eea) : Colors.grey,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Specifications
                      Text(
                        'Specifications',
                        style: TextStyle(fontSize: isDesktop ? 20 : 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildSpecRow('Brand', widget.laptop.brand, isDesktop),
                      _buildSpecRow('Model', widget.laptop.model, isDesktop),
                      _buildSpecRow('Processor', widget.laptop.processor, isDesktop),
                      _buildSpecRow('RAM', widget.laptop.ram, isDesktop),
                      _buildSpecRow('Storage', widget.laptop.storage, isDesktop),
                      _buildSpecRow('Graphics', widget.laptop.graphics, isDesktop),
                      _buildSpecRow('Screen', '${widget.laptop.screenSize}" ${widget.laptop.displayType}', isDesktop),
                      _buildSpecRow('Price', _formatINR(widget.laptop.price), isDesktop),
                      _buildSpecRow('Stock', '${widget.laptop.stock} available', isDesktop),
                      const SizedBox(height: 16),
                      Text(widget.laptop.description, style: TextStyle(fontSize: isDesktop ? 16 : 14, color: Colors.grey[700])),

                      const SizedBox(height: 24),

                      // WhatsApp and Phone buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _launchWhatsApp,
                              icon: const Icon(Icons.chat, color: Colors.white),
                              label: const Text('Chat on WhatsApp'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _launchPhoneDialer,
                              icon: const Icon(Icons.phone, color: Colors.white),
                              label: const Text('Call Now'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isDesktop ? 120 : 100,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isDesktop ? 16 : 14, color: Colors.grey[600])),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: isDesktop ? 16 : 14))),
        ],
      ),
    );
  }
}