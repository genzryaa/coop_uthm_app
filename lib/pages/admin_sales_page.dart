import 'package:flutter/material.dart';
import '../data/coop_data.dart';

class AdminSalesPage extends StatelessWidget {
  const AdminSalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Ledger (${coopState.orders.length} Orders)'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: coopState.orders.length,
        itemBuilder: (context, index) {
          final order = coopState.orders[index];
          return Card(
            child: ListTile(
              leading: Icon(
                order.isPickedUp ? Icons.check_circle : Icons.pending_actions,
                color: order.isPickedUp ? Colors.green : Colors.orange,
                size: 32,
              ),
              title: Text(
                '${order.orderId} • RM ${order.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Buyer: ${order.buyerName}\n${order.itemCount} items • ${order.paymentMethod}',
              ),
              isThreeLine: true,
              trailing: FilledButton.tonal(
                onPressed: () => coopState.toggleOrderPickup(order),
                child: Text(order.isPickedUp ? 'Completed' : 'Verify Pickup'),
              ),
            ),
          );
        },
      ),
    );
  }
}