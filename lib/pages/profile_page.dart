import 'package:flutter/material.dart';
import '../data/coop_data.dart';
import 'login_page.dart';

class ProfileOrdersPage extends StatelessWidget {
  const ProfileOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Receipts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(coopState.currentUserName),
              subtitle: Text(coopState.currentUserEmail),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Completed Coop Orders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...coopState.orders.map(
            (order) => Card(
              child: ListTile(
                leading: const Icon(Icons.verified, color: Colors.green),
                title: Text(
                  '${order.orderId} • RM ${order.total.toStringAsFixed(2)}',
                ),
                subtitle: Text(
                  '${order.itemCount} items • ${order.paymentMethod}',
                ),
                trailing: const Chip(label: Text('PAID')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}