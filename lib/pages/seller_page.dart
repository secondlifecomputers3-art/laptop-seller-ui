import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/laptop_provider.dart';
import '../models/laptop.dart';
import '../widgets/laptop_card.dart';
import 'add_edit_laptop_page.dart';

class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  String _searchQuery = '';
  bool _isLoading = false;

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

  String _formatLargeINR(double value) {
    if (value >= 10000000) {
      double crores = value / 10000000;
      return '₹${crores.toStringAsFixed(2)} Cr';
    } else if (value >= 100000) {
      double lakhs = value / 100000;
      return '₹${lakhs.toStringAsFixed(2)} L';
    } else {
      return _formatINR(value);
    }
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth > 1200) return 5;
    if (screenWidth > 800) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  List<Laptop> _filterLaptops(List<Laptop> laptops, String query) {
    if (query.isEmpty) return laptops;
    return laptops.where((l) =>
      l.brand.toLowerCase().contains(query.toLowerCase()) ||
      l.model.toLowerCase().contains(query.toLowerCase()) ||
      l.processor.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory refreshed!'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
      );
    }
  }

  Future<void> _showChangePasswordDialog() async {
    TextEditingController newPassController = TextEditingController();
    TextEditingController confirmController = TextEditingController();

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Seller Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPassController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password cannot be empty')),
                );
                return;
              }
              if (newPassController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              final provider = Provider.of<LaptopProvider>(context, listen: false);
              await provider.setSellerPassword(newPassController.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LaptopProvider>(
      builder: (context, provider, child) {
        final filteredLaptops = _filterLaptops(provider.laptops, _searchQuery);
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
            final isDesktop = constraints.maxWidth > 800;
            final isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 800;
            final isMobile = constraints.maxWidth <= 600;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Seller Dashboard'),
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                automaticallyImplyLeading: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: _showChangePasswordDialog,
                    tooltip: 'Change Password',
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Logout',
                  ),
                ],
              ),
              body: SafeArea(
                bottom: true,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : CustomScrollView(
                          slivers: [
                            // Search bar (desktop only)
                            if (isDesktop)
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                sliver: SliverToBoxAdapter(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: TextField(
                                      onChanged: (v) => setState(() => _searchQuery = v),
                                      decoration: InputDecoration(
                                        hintText: 'Search in inventory...',
                                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                      ),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),

                            // Stats cards
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                isDesktop ? 16 : 12,
                                isDesktop ? 16 : 12,
                                isDesktop ? 16 : 12,
                                0,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: isDesktop
                                    ? Row(
                                        children: [
                                          Expanded(child: _buildStatCard('Total Products', provider.totalLaptops.toString(), Icons.inventory_2, const Color(0xFF667eea))),
                                          const SizedBox(width: 16),
                                          Expanded(child: _buildStatCard('Total Stock', provider.totalStock.toString(), Icons.warehouse, Colors.green)),
                                          const SizedBox(width: 16),
                                          Expanded(child: _buildStatCard('Inventory Value', _formatLargeINR(provider.totalValue), Icons.account_balance_wallet, Colors.orange)),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          _buildStatCard('Total Products', provider.totalLaptops.toString(), Icons.inventory_2, const Color(0xFF667eea)),
                                          const SizedBox(height: 8),
                                          _buildStatCard('Total Stock', provider.totalStock.toString(), Icons.warehouse, Colors.green),
                                          const SizedBox(height: 8),
                                          _buildStatCard('Inventory Value', _formatLargeINR(provider.totalValue), Icons.account_balance_wallet, Colors.orange),
                                        ],
                                      ),
                              ),
                            ),

                            // Title and add button
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                isDesktop ? 16 : 12,
                                16,
                                isDesktop ? 16 : 12,
                                0,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.inventory, color: Colors.white, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Manage Inventory',
                                          style: TextStyle(
                                            fontSize: isDesktop ? 20 : 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    FloatingActionButton(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const AddEditLaptopPage(),
                                          ),
                                        );
                                        setState(() {});
                                      },
                                      child: Icon(Icons.add, size: isDesktop ? 28 : 24),
                                      mini: isMobile,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SliverToBoxAdapter(child: SizedBox(height: 16)),

                            // Laptop grid
                            filteredLaptops.isEmpty
                                ? SliverFillRemaining(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.inventory_outlined,
                                            size: isDesktop ? 100 : 80,
                                            color: Colors.white.withOpacity(0.5),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            _searchQuery.isEmpty
                                                ? 'No laptops in inventory'
                                                : 'No laptops match your search',
                                            style: TextStyle(
                                              fontSize: isDesktop ? 20 : 16,
                                              color: Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          if (_searchQuery.isEmpty)
                                            Text(
                                              'Click the + button to add your first laptop',
                                              style: TextStyle(
                                                fontSize: isDesktop ? 16 : 14,
                                                color: Colors.white.withOpacity(0.6),
                                              ),
                                            ),
                                          const SizedBox(height: 20),
                                          if (_searchQuery.isEmpty)
                                            ElevatedButton.icon(
                                              onPressed: () async {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => const AddEditLaptopPage(),
                                                  ),
                                                );
                                                setState(() {});
                                              },
                                              icon: const Icon(Icons.add),
                                              label: const Text('Add First Laptop'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: const Color(0xFF667eea),
                                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                : SliverPadding(
                                    padding: EdgeInsets.only(
                                      left: isDesktop ? 20 : 12,
                                      right: isDesktop ? 20 : 12,
                                      bottom: 20,
                                    ),
                                    sliver: SliverGrid(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: 0.7,
                                        crossAxisSpacing: isDesktop ? 20 : (isTablet ? 16 : 12),
                                        mainAxisSpacing: isDesktop ? 20 : (isTablet ? 16 : 12),
                                      ),
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final laptop = filteredLaptops[index];
                                          return LaptopCard(
                                            laptop: laptop,
                                            isSellerMode: true,
                                            onEdit: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AddEditLaptopPage(
                                                    laptop: laptop,
                                                  ),
                                                ),
                                              );
                                              setState(() {});
                                            },
                                            onDelete: () {
                                              _showDeleteDialog(context, laptop);
                                            },
                                          );
                                        },
                                        childCount: filteredLaptops.length,
                                      ),
                                    ),
                                  ),

                            // Extra bottom padding
                            const SliverToBoxAdapter(child: SizedBox(height: 20)),
                          ],
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Laptop laptop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Laptop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete ${laptop.brand} ${laptop.model}?'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _isLoading = true);
              try {
                await Provider.of<LaptopProvider>(context, listen: false).deleteLaptop(laptop.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${laptop.brand} ${laptop.model} deleted'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}