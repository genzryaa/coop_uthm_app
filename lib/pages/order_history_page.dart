import 'package:flutter/material.dart';
import '../data/coop_data.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  void _showDigitalReceipt(BuildContext context, OrderRecord order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Column(
          children: [
            Image.asset(
              'assets/images/coop_uthm_logo.png',
              height: 44,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            const Text(
              'OFFICIAL DIGITAL RECEIPT',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order.orderId}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Customer: ${order.buyerName}'),
            Text(
              'Date: ${order.date.day}/${order.date.month}/${order.date.year} '
              '${order.date.hour.toString().padLeft(2, '0')}:${order.date.minute.toString().padLeft(2, '0')}',
            ),
            Text('Payment: ${order.paymentMethod}'),
            Text(
              'Status: ${order.isPickedUp ? "PICKED UP" : "PAID - READY FOR PICKUP"}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: order.isPickedUp ? Colors.green : Colors.orange,
              ),
            ),
            const Divider(height: 20),
            if (order.itemsSummary.isNotEmpty) ...[
              const Text('Items:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...order.itemsSummary.map((line) => Text('• $line')),
              const Divider(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL PAID',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'RM ${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFFE60000),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: coopState,
      builder: (context, _) {
        final myOrders = coopState.orders.where((o) {
          if (coopState.currentUserEmail.isEmpty) return true;
          return o.buyerEmail.isEmpty ||
              o.buyerEmail == coopState.currentUserEmail;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(coopState.tr('order_history')),
          ),
          body: myOrders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No orders yet. Checkout items to get a receipt!'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: myOrders.length,
                  itemBuilder: (context, idx) {
                    final order = myOrders[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.orderId,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    order.isPickedUp ? 'PICKED UP' : 'PAID',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: order.isPickedUp
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : Colors.amber.withValues(alpha: 0.2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${order.date.day}/${order.date.month}/${order.date.year} • ${order.paymentMethod}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${order.itemCount} item(s) • RM ${order.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.receipt_long, size: 18),
                                  label: Text(coopState.tr('view_receipt')),
                                  onPressed: () =>
                                      _showDigitalReceipt(context, order),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}