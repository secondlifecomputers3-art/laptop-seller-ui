import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              width: 64,
              height: 64,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Second Life Computers',
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: isDesktop ? 20 : 16,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
                    ),
                    softWrap: true,
                  ),
                  Text(
                    'Renewed And Ready To Use',
                    style: GoogleFonts.openSans(
                      color: Colors.white70,
                      fontSize: isDesktop ? 14 : 10,
                      fontWeight: FontWeight.normal,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}