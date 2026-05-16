import 'dart:convert';
import 'package:flutter/material.dart';
import '../pages/laptop_detail_page.dart';
import '../models/laptop.dart';

class LaptopCard extends StatelessWidget {
  final Laptop laptop;
  final bool isSellerMode;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LaptopCard({
    super.key,
    required this.laptop,
    this.isSellerMode = false,
    this.onEdit,
    this.onDelete,
  });

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

  String _shortenText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  ImageProvider _getImageProvider(String url, bool isAsset) {
    print('Loading image: $url, isAsset: $isAsset');
    if (url.startsWith('data:image')) {
      final base64String = url.split(',').last;
      return MemoryImage(base64Decode(base64String));
    } else if (isAsset) {
      return AssetImage(url);
    } else {
      return NetworkImage(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final imageToShow = laptop.thumbnailUrl.isNotEmpty ? laptop.thumbnailUrl : laptop.imageUrl;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LaptopDetailPage(laptop: laptop),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      image: DecorationImage(
                        image: _getImageProvider(imageToShow, laptop.isAsset),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          print('Error loading image: $imageToShow, exception: $exception');
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: laptop.stock > 0 ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        laptop.stock > 0 ? 'In Stock' : 'Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 10 : 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 8 : 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          laptop.brand,
                          style: TextStyle(fontSize: isDesktop ? 11 : 9, color: Colors.grey),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          laptop.model,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: isDesktop ? 13 : 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    _buildSpecRow('🖥️', _shortenText(laptop.processor, isDesktop ? 16 : 8), isDesktop),
                    _buildSpecRow('💾', '${laptop.ram} / ${_shortenText(laptop.storage, isDesktop ? 10 : 5)}', isDesktop),
                    _buildSpecRow('📺', '${laptop.screenSize}" ${_shortenText(laptop.displayType, isDesktop ? 10 : 5)}', isDesktop),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatINR(laptop.price),
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF667eea),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            'Qty: ${laptop.stock}',
                            style: TextStyle(fontSize: isDesktop ? 9 : 8, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    if (isSellerMode) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: const Color(0xFF667eea),
                              borderRadius: BorderRadius.circular(4),
                              child: InkWell(
                                onTap: onEdit,
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: isDesktop ? 6 : 2),
                                  child: const Center(
                                    child: Text('Edit', style: TextStyle(color: Colors.white, fontSize: 10)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                              child: InkWell(
                                onTap: onDelete,
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: isDesktop ? 6 : 2),
                                  child: const Center(
                                    child: Text('Delete', style: TextStyle(color: Colors.white, fontSize: 10)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String icon, String text, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.5),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: isDesktop ? 11 : 9)),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: isDesktop ? 9 : 8, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}