import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String _selectedStatus = 'All';
  final List<String> _statuses = ['All', 'Pending', 'Completed', 'Cancelled'];

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  void _showReceiptModal(BuildContext context, String orderId, Map<String, dynamic> data) {
    final items = (data['items'] as List<dynamic>?) ?? [];
    final total = (data['totalAmount'] ?? 0.0).toDouble();
    final paymentMethod = data['paymentMethod'] ?? 'N/A';
    final paymentRef = data['paymentRef'] ?? 'N/A';
    final Timestamp? timestamp = data['createdAt'];
    final dateStr = timestamp != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate())
        : 'N/A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Center(
              child: Column(
                children: [
                  Icon(Icons.storefront, size: 36),
                  SizedBox(height: 4),
                  Text(
                    'KOPERASI UTHM BERHAD',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text('Parit Raja, 86400 Batu Pahat, Johor', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const Divider(height: 24),
            Text('Receipt No: #${orderId.substring(0, 8).toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Date: $dateStr'),
            Text('Payment Method: $paymentMethod'),
            Text('Ref ID: $paymentRef'),
            const Divider(height: 24),
            const Text('Purchased Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.map((item) {
              final name = item['name'] ?? 'Item';
              final qty = item['quantity'] ?? 1;
              final price = (item['price'] ?? 0.0).toDouble();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('$qty x $name')),
                    Text('RM ${(price * qty).toStringAsFixed(2)}'),
                  ],
                ),
              );
            }),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL PAID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  'RM ${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close Receipt'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: Column(
        children: [
          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _statuses.map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: _selectedStatus == status,
                    onSelected: (_) => setState(() => _selectedStatus = status),
                  ),
                );
              }).toList(),
            ),
          ),
          // Orders List
          Expanded(
            child: user == null
                ? const Center(child: Text('Please log in to view orders.'))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orders')
                        .where('userId', isEqualTo: user.uid)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No orders found yet.'));
                      }

                      final docs = snapshot.data!.docs.where((doc) {
                        if (_selectedStatus == 'All') return true;
                        final status = (doc['status'] ?? 'Pending').toString();
                        return status.toLowerCase() == _selectedStatus.toLowerCase();
                      }).toList();

                      if (docs.isEmpty) {
                        return Center(child: Text('No $_selectedStatus orders.'));
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
                          final items = (data['items'] as List<dynamic>?) ?? [];
                          final isCompleted = status.toString().toLowerCase() == 'completed';

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
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(status).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            color: _getStatusColor(status),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('${items.length} item(s) • Paid via $method'),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'RM ${total.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      if (isCompleted)
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.receipt_long, size: 18),
                                          label: const Text('Get Receipt'),
                                          onPressed: () =>
                                              _showReceiptModal(context, doc.id, data),
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
          ),
        ],
      ),
    );
  }
}