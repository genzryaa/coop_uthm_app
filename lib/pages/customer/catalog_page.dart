import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_locale_provider.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List> _categories = [
    {'name': 'All', 'labelBm': 'Semua Kategori', 'icon': Icons.apps},
    {'name': 'Stationery & Lab', 'labelBm': 'Alat Tulis & Makmal', 'icon': Icons.science_outlined},
    {'name': 'UTHM Merch', 'labelBm': 'Cenderamata UTHM', 'icon': Icons.checkroom_outlined},
    {'name': 'Snacks & Drinks', 'labelBm': 'Makanan & Minuman', 'icon': Icons.local_cafe_outlined},
    {'name': 'Daily Essentials', 'labelBm': 'Keperluan Harian', 'icon': Icons.shopping_bag_outlined},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Stationery & Lab':
        return Icons.edit_note;
      case 'UTHM Merch':
        return Icons.school;
      case 'Snacks & Drinks':
        return Icons.fastfood;
      case 'Daily Essentials':
      default:
        return Icons.inventory_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final isBm = Provider.of<ThemeLocaleProvider>(context).locale.languageCode == 'ms';
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBm ? 'Katalog Koperasi UTHM' : 'UTHM Co-op Catalog'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              controller: _searchController,
              hintText: isBm ? 'Cari barangan koperasi...' : 'Search items in UTHM Co-op...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
              ],
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),
        ),
      ),

      // Category Sidebar (NavigationDrawer)
      drawer: NavigationDrawer(
        selectedIndex: _categories.indexWhere((c) => c['name'] == _selectedCategory),
        onDestinationSelected: (index) {
          setState(() => _selectedCategory = _categories[index]['name']);
          Navigator.pop(context); // Close sidebar
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 16, 10),
            child: Text(
              isBm ? 'Kategori Barangan' : 'Item Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(indent: 28, endIndent: 28),
          ..._categories.map(
            (cat) => NavigationDrawerDestination(
              icon: Icon(cat['icon'] as IconData),
              label: Text(isBm ? cat['labelBm'] : cat['name']),
            ),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Category Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${isBm ? "Kategori" : "Category"}: $_selectedCategory',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.menu_open, size: 18),
                  label: Text(isBm ? 'Tukar' : 'Filter'),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ],
            ),
          ),

          // Live Product Grid from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      isBm
                          ? 'Tiada produk ditemui. Sila tambah melalui Admin.'
                          : 'No products available yet. Seed items via Admin Dashboard.',
                    ),
                  );
                }

                // Filter by Sidebar Category & Top Search Query
                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final category = (data['category'] ?? '').toString();

                  final matchesCategory =
                      _selectedCategory == 'All' || category == _selectedCategory;
                  final matchesSearch =
                      _searchQuery.isEmpty || name.contains(_searchQuery);

                  return matchesCategory && matchesSearch;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(isBm ? 'Tiada padanan carian.' : 'No matching items found.'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isLandscape ? 4 : 2,
                    childAspectRatio: 0.76,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Product';
                    final price = (data['price'] ?? 0.0).toDouble();
                    final category = data['category'] ?? 'General';
                    final stock = data['stock'] ?? 0;

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getCategoryIcon(category),
                                  size: 44,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'RM ${price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${isBm ? "Stok" : "Stock"}: $stock',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.tonalIcon(
                                icon: const Icon(Icons.add_shopping_cart, size: 16),
                                label: Text(isBm ? 'Tambah' : 'Add'),
                                onPressed: stock > 0
                                    ? () {
                                        cart.addItem(
                                          id: doc.id,
                                          name: name,
                                          price: price,
                                          category: category,
                                        );
                                        ScaffoldMessenger.of(context)
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: Text('$name added to cart'),
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}