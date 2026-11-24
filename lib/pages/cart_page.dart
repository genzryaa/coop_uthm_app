import 'package:flutter/material.dart';
import '../data/coop_data.dart';

class CartCheckoutPage extends StatelessWidget {
  const CartCheckoutPage({super.key});

  void _openSimpleStripeSheet(BuildContext context) {
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Stripe Sandbox Checkout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: const Text(
                          'TEST MODE',
                          style: TextStyle(fontSize: 11),
                        ),
                        backgroundColor: Colors.amber.shade100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Test Card Number',
                      hintText: '4242 •••• •••• 4242',
                      prefixIcon: Icon(Icons.credit_card),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Expiry',
                            hintText: '12/28',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'CVC',
                            hintText: '424',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            setModalState(() => isProcessing = true);
                            await Future.delayed(const Duration(seconds: 1));
                            final receipt =
                                coopState.completeStripeMockCheckout();
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  icon: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 56,
                                  ),
                                  title: const Text('Payment Successful!'),
                                  content: Text(
                                    'Order ID: ${receipt.orderId}\n'
                                    'Paid: RM ${receipt.total.toStringAsFixed(2)}\n'
                                    'Status: Ready for Coop Pickup',
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Done'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Pay RM ${coopState.totalCartAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Shopping Cart')),
      body: coopState.cart.isEmpty
          ? const Center(
              child: Text(
                'Your Coop cart is empty.\nAdd items from the Catalog!',
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: coopState.cart.length,
                    itemBuilder: (context, index) {
                      final item = coopState.cart[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.product.color.withOpacity(0.15),
                          child: Icon(
                            item.product.icon,
                            color: item.product.color,
                          ),
                        ),
                        title: Text(item.product.name),
                        subtitle: Text(
                          'RM ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () =>
                                  coopState.updateQuantity(item.product, -1),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () =>
                                  coopState.updateQuantity(item.product, 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Payable:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'RM ${coopState.totalCartAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => _openSimpleStripeSheet(context),
                        icon: const Icon(Icons.payment),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Checkout with Stripe (Test Card)'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}