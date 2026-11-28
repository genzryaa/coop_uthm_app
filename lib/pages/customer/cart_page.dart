import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_locale_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String _selectedPaymentMethod = 'Card (Stripe)';
  String _selectedBank = 'Maybank2u';
  String _selectedWallet = 'Touch \'n Go eWallet';
  bool _isProcessing = false;

  final List> _paymentMethods = [
    {'label': 'Card (Stripe)', 'icon': Icons.credit_card},
    {'label': 'Online Banking (FPX)', 'icon': Icons.account_balance},
    {'label': 'E-Wallet', 'icon': Icons.account_balance_wallet},
    {'label': 'QR Code', 'icon': Icons.qr_code_2},
    {'label': 'Pay at Counter', 'icon': Icons.storefront},
  ];

  void _openCheckoutSheet(BuildContext context, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Select Payment Method',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // 5 Payment Method Options
                    ..._paymentMethods.map((method) {
                      final label = method['label'] as String;
                      return RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        secondary: Icon(method['icon'] as IconData),
                        title: Text(label),
                        value: label,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (val) {
                          setSheetState(() => _selectedPaymentMethod = val!);
                        },
                      );
                    }),

                    // Dynamic Sub-options per Payment Method
                    if (_selectedPaymentMethod == 'Online Banking (FPX)')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: DropdownButtonFormField<String>(
                          value: _selectedBank,
                          decoration: const InputDecoration(
                            labelText: 'Choose Bank',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Maybank2u', 'CIMB Clicks', 'Bank Islam', 'RHB Now']
                              .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                              .toList(),
                          onChanged: (val) => setSheetState(() => _selectedBank = val!),
                        ),
                      ),

                    if (_selectedPaymentMethod == 'E-Wallet')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: DropdownButtonFormField<String>(
                          value: _selectedWallet,
                          decoration: const InputDecoration(
                            labelText: 'Choose E-Wallet',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Touch \'n Go eWallet', 'GrabPay', 'ShopeePay']
                              .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                              .toList(),
                          onChanged: (val) => setSheetState(() => _selectedWallet = val!),
                        ),
                      ),

                    if (_selectedPaymentMethod == 'QR Code')
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.qr_code_2, size: 130),
                            Text(
                              'Scan DuitNow QR • Koperasi UTHM Berhad',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),

                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Payable:', style: TextStyle(fontSize: 16)),
                        Text(
                          'RM ${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    FilledButton(
                      onPressed: _isProcessing
                          ? null
                          : () async {
                              setSheetState(() => _isProcessing = true);
                              await _submitOrder(sheetContext, cart);
                              setSheetState(() => _isProcessing = false);
                            },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Confirm & Pay'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitOrder(BuildContext sheetContext, CartProvider cart) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Build detailed payment label & mock payment token (Stripe/FPX/QR/Counter)
    String methodDetail = _selectedPaymentMethod;
    String prefix = 'TXN';
    if (_selectedPaymentMethod == 'Card (Stripe)') {
      // Note: Connect Stripe.instance.presentPaymentSheet() here if using live test keys
      prefix = 'pi_stripe_test';
    } else if (_selectedPaymentMethod == 'Online Banking (FPX)') {
      methodDetail = 'FPX ($_selectedBank)';
      prefix = 'FPX';
    } else if (_selectedPaymentMethod == 'E-Wallet') {
      methodDetail = 'E-Wallet ($_selectedWallet)';
      prefix = 'EW';
    } else if (_selectedPaymentMethod == 'QR Code') {
      prefix = 'QR';
    } else {
      prefix = 'CTR';
    }

    final paymentRef = '$prefix-${DateTime.now().millisecondsSinceEpoch}';

    // Instant digital methods can default to 'Pending' for admin verification (or 'Completed')
    final orderData = {
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'items': cart.items.values.map((item) => item.toMap()).toList(),
      'totalAmount': cart.totalAmount,
      'paymentMethod': methodDetail,
      'paymentRef': paymentRef,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('orders').add(orderData);
    await cart.clearCart();

    if (sheetContext.mounted) {
      Navigator.pop(sheetContext);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order submitted! Ref: $paymentRef (Check Orders tab)'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isBm = Provider.of<ThemeLocaleProvider>(context).locale.languageCode == 'ms';
    final cartList = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isBm ? 'Troli Belian' : 'Shopping Cart'),
        actions: [
          if (cartList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Cart',
              onPressed: () => cart.clearCart(),
            ),
        ],
      ),
      body: cartList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(isBm ? 'Troli anda kosong.' : 'Your cart is empty.'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cartList.length,
                    itemBuilder: (context, index) {
                      final item = cartList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'RM ${item.price.toStringAsFixed(2)} x ${item.quantity} = RM ${(item.price * item.quantity).toStringAsFixed(2)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => cart.updateQuantity(item.id, -1),
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => cart.updateQuantity(item.id, 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Checkout Summary Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isBm ? 'Jumlah Keseluruhan' : 'Total Amount'),
                          Text(
                            'RM ${cart.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      FilledButton.icon(
                        icon: const Icon(Icons.payment),
                        label: Text(isBm ? 'Bayar Sekarang' : 'Checkout'),
                        onPressed: () => _openCheckoutSheet(context, cart),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}