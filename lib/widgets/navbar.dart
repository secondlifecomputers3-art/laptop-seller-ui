import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final VoidCallback onLogoLongPress;

  const Navbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onLogoLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onLongPress: onLogoLongPress,
        child: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Second Life Computers - Renewed And Ready To Use',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 20 : 14,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}