import 'package:flutter/material.dart';
import '../data/coop_data.dart';

class AdminInventoryPage extends StatelessWidget {
  const AdminInventoryPage({super.key});

  void _showAddProductDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '20');
    String selectedCat = 'Snacks';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Add Coop Retail Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCat,
                  decoration: const InputDecoration(
                    labelText: 'Retail Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Snacks', 'Beverages', 'Stationery', 'Essentials']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setModalState(() => selectedCat = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price (RM)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Initial Stock Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final price = double.tryParse(priceCtrl.text) ?? 0.0;
                final stock = int.tryParse(stockCtrl.text) ?? 10;
                if (nameCtrl.text.isNotEmpty && price > 0) {
                  await coopState.addNewProduct(
                      nameCtrl.text, selectedCat, price, stock);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Manager (${coopState.products.length} SKUs)'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        icon: const Icon(Icons.add_box),
        label: const Text('New Product'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: coopState.products.length,
        itemBuilder: (context, index) {
          final item = coopState.products[index];
          final isLow = item.stock <= 5;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: item.color.withValues(alpha: 0.15),
              child: Icon(item.icon, color: item.color),
            ),
            title: Text(item.name),
            subtitle: Text(
              '${item.category} • RM ${item.price.toStringAsFixed(2)} • Stock: ${item.stock}',
              style: TextStyle(
                color: isLow ? Colors.red : null,
                fontWeight: isLow ? FontWeight.bold : null,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Restock +10',
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.green),
                  onPressed: () => coopState.restockProduct(item, 10),
                ),
                IconButton(
                  tooltip: 'Delete Item',
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => coopState.deleteProduct(item),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}