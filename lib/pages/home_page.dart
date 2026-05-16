import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/laptop_provider.dart';
import '../widgets/laptop_card.dart';
import '../widgets/navbar.dart';
import 'seller_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';

  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth > 1200) return 0.7;
    if (screenWidth > 800) return 0.7;
    if (screenWidth > 600) return 0.65;
    return 0.6;
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth > 1200) return 4;
    if (screenWidth > 800) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  Future<void> _showPasswordDialog() async {
    TextEditingController passwordController = TextEditingController();
    final provider = Provider.of<LaptopProvider>(context, listen: false);
    final storedPassword = await provider.getSellerPassword();

    bool? success = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seller Login'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text == storedPassword) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect password')),
                );
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );

    if (success == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SellerPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Navbar(
                selectedIndex: 0,
                onItemTapped: (index) {},
                onLogoLongPress: _showPasswordDialog,
              ),
              Expanded(child: _buildHomePage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return Consumer<LaptopProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.laptops.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.white.withOpacity(0.7)),
                const SizedBox(height: 16),
                Text(
                  'Error loading laptops',
                  style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadLaptops(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF667eea),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final laptops = provider.searchLaptops(_searchQuery);
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
            final aspectRatio = _getChildAspectRatio(constraints.maxWidth);
            final isDesktop = constraints.maxWidth > 800;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(isDesktop ? 20 : 10),
                  child: Column(
                    children: [
                      Text(
                        'Find Your Laptop',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 24 : 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: isDesktop ? 45 : 35,
                        width: isDesktop ? 500 : double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: TextStyle(fontSize: isDesktop ? 16 : 13),
                          decoration: InputDecoration(
                            hintText: 'Search laptops...',
                            hintStyle: TextStyle(fontSize: isDesktop ? 16 : 13, color: Colors.grey),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, size: isDesktop ? 20 : 16, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: laptops.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.computer, size: isDesktop ? 80 : 60, color: Colors.white.withOpacity(0.5)),
                              const SizedBox(height: 15),
                              Text(
                                'No laptops found',
                                style: TextStyle(fontSize: isDesktop ? 18 : 16, color: Colors.white.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(isDesktop ? 20 : 8),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: aspectRatio,
                            crossAxisSpacing: isDesktop ? 20 : 8,
                            mainAxisSpacing: isDesktop ? 20 : 8,
                          ),
                          itemCount: laptops.length,
                          itemBuilder: (context, index) => LaptopCard(
                            laptop: laptops[index],
                            isSellerMode: false,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}