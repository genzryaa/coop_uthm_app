import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final List<String> _categories = [
    'Stationery & Lab',
    'UTHM Merch',
    'Snacks & Drinks',
    'Daily Essentials',
  ];

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  /// Seeds 10 items per category (40 total items) into Firestore for quick setup & demo
  Future<void> _seedSampleCatalog() async {
    final sampleData = <String, List>{
      'Stationery & Lab': [
        {'name': 'UTHM Official Lanyard', 'price': 8.00, 'stock': 50},
        {'name': 'UTHM Engineering Lab Coat', 'price': 45.00, 'stock': 30},
        {'name': 'Scientific Calculator FX-570EX', 'price': 68.00, 'stock': 20},
        {'name': 'A4 Foolscap Test Pad (100s)', 'price': 5.50, 'stock': 80},
        {'name': 'Technical Drawing Pen 0.5mm', 'price': 6.90, 'stock': 40},
        {'name': 'Engineering Graph Book', 'price': 4.20, 'stock': 60},
        {'name': 'Hardcover Project Logbook', 'price': 12.00, 'stock': 45},
        {'name': 'Pastel Highlighter Set (6 pcs)', 'price': 9.50, 'stock': 35},
        {'name': 'Correction Tape 12m', 'price': 3.50, 'stock': 70},
        {'name': 'Mini Stapler & Refill Set', 'price': 5.00, 'stock': 50},
      ],
      'UTHM Merch': [
        {'name': 'UTHM Corporate Batik Shirt', 'price': 65.00, 'stock': 25},
        {'name': 'UTHM Varsity Hoodie (Navy)', 'price': 85.00, 'stock': 20},
        {'name': 'UTHM Convocation Teddy Bear', 'price': 38.00, 'stock': 15},
        {'name': 'Canvas Totebag UTHM Edition', 'price': 15.00, 'stock': 40},
        {'name': 'Insulated Stainless Tumbler 500ml', 'price': 28.00, 'stock': 30},
        {'name': 'UTHM Alumni Car Decal Sticker', 'price': 4.00, 'stock': 100},
        {'name': 'UTHM Crest Enamel Lapel Pin', 'price': 10.00, 'stock': 50},
        {'name': 'Matric Card Hardcase Holder', 'price': 3.50, 'stock': 90},
        {'name': 'UTHM Embroidered Baseball Cap', 'price': 22.00, 'stock': 35},
        {'name': 'UTHM Foldable Windproof Umbrella', 'price': 25.00, 'stock': 30},
      ],
      'Snacks & Drinks': [
        {'name': 'Mineral Water 1.5L', 'price': 2.20, 'stock': 120},
        {'name': 'Milo UHT Packet 200ml', 'price': 2.50, 'stock': 100},
        {'name': 'Nescafe Original Can 240ml', 'price': 3.20, 'stock': 80},
        {'name': 'Gardenia Cream Roll (Corn)', 'price': 1.50, 'stock': 60},
        {'name': 'Maggi Hot Cup Curry', 'price': 2.80, 'stock': 90},
        {'name': 'Hup Seng Cream Crackers', 'price': 4.80, 'stock': 45},
        {'name': 'Mister Potato Crisps Can', 'price': 5.20, 'stock': 50},
        {'name': 'Cadbury Dairy Milk 60g', 'price': 4.50, 'stock': 65},
        {'name': '100PLUS Isotonic Bottle 500ml', 'price': 2.80, 'stock': 85},
        {'name': 'Oreo Vanilla Sandwich Pack', 'price': 3.60, 'stock': 70},
      ],
      'Daily Essentials': [
        {'name': 'Colgate Toothpaste 175g', 'price': 7.90, 'stock': 40},
        {'name': 'Dettol Anti-Bacterial Bar Soap', 'price': 4.20, 'stock': 55},
        {'name': 'Daia Laundry Detergent 850g', 'price': 6.50, 'stock': 35},
        {'name': 'Premier Facial Tissue Box', 'price': 3.80, 'stock': 60},
        {'name': 'Instant Hand Sanitizer 50ml', 'price': 4.50, 'stock': 75},
        {'name': '3-Ply Surgical Face Mask (50s)', 'price': 8.90, 'stock': 40},
        {'name': 'Panadol Actifast Strip (10s)', 'price': 5.80, 'stock': 50},
        {'name': 'Waterproof Adhesive Plasters', 'price': 3.20, 'stock': 65},
        {'name': 'Hostel Locker Brass Padlock', 'price': 9.00, 'stock': 30},
        {'name': 'Heavy Duty Clothes Hangers (6s)', 'price': 6.00, 'stock': 45},
      ],
    };

    final batch = FirebaseFirestore.instance.batch();
    final productsRef = FirebaseFirestore.instance.collection('products');

    sampleData.forEach((category, items) {
      for (final item in items) {
        final docRef = productsRef.doc();
        batch.set(docRef, {
          'name': item['name'],
          'price': item['price'],
          'stock': item['stock'],
          'category': category,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });

    await batch.commit();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seeded 40 items (10 per category) to Firestore!')),
      );
    }
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController(text: '20');
    String selectedCategory = _categories.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedCategory = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Price (RM)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock Quantity'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                final stock = int.tryParse(stockController.text.trim()) ?? 0;
                if (name.isEmpty || price <= 0) return;

                await FirebaseFirestore.instance.collection('products').add({
                  'name': name,
                  'category': selectedCategory,
                  'price': price,
                  'stock': stock,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': newStatus});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked as $newStatus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Co-op Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.playlist_add_check),
              tooltip: 'Seed 10 Items/Category',
              onPressed: _seedSampleCatalog,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.receipt_long), text: 'Customer Orders'),
              Tab(icon: Icon(Icons.inventory_2), text: 'Catalog Inventory'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: Manage Orders (Approve Pending -> Completed / Cancelled)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No customer orders yet.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'Pending';
                    final total = (data['totalAmount'] ?? 0.0).toDouble();
                    final method = data['paymentMethod'] ?? 'N/A';
                    final email = data['userEmail'] ?? 'Customer';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order #${doc.id.substring(0, 8).toUpperCase()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Chip(label: Text(status)),
                              ],
                            ),
                            Text('Customer: $email'),
                            Text('Payment: $method • RM ${total.toStringAsFixed(2)}'),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (status != 'Cancelled')
                                  OutlinedButton(
                                    onPressed: () =>
                                        _updateOrderStatus(doc.id, 'Cancelled'),
                                    child: const Text('Cancel'),
                                  ),
                                const SizedBox(width: 8),
                                if (status != 'Completed')
                                  FilledButton(
                                    onPressed: () =>
                                        _updateOrderStatus(doc.id, 'Completed'),
                                    child: const Text('Mark Completed'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // TAB 2: Manage Inventory
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .orderBy('category')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No products in database yet.'),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Seed 40 Sample Items (10/Category)'),
                          onPressed: _seedSampleCatalog,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text(data['name'] ?? ''),
                        subtitle: Text(
                          '${data['category']} • RM ${(data['price'] ?? 0.0).toStringAsFixed(2)} • Stock: ${data['stock'] ?? 0}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => doc.reference.delete(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddProductDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
        ),
      ),
    );
  }
}