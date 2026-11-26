import 'package:flutter/material.dart';
import '../data/coop_data.dart';

class CartCheckoutPage extends StatefulWidget {
  const CartCheckoutPage({super.key});

  @override
  State<CartCheckoutPage> createState() => _CartCheckoutPageState();
}

class _CartCheckoutPageState extends State<CartCheckoutPage> {
  String _selectedPayment = 'E-Wallet';
  String _selectedEwallet = 'Touch \'n Go eWallet';
  String _selectedBank = 'Maybank2u';
  bool _isProcessing = false;

  final List> _paymentOptions = [
    {
      'id': 'E-Wallet',
      'title': 'E-Wallet',
      'subtitle': 'Touch \'n Go, GrabPay, ShopeePay',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'id': 'QR Code',
      'title': 'DuitNow QR Code',
      'subtitle': 'Scan instant QR to pay',
      'icon': Icons.qr_code_2,
    },
    {
      'id': 'Online Banking (FPX)',
      'title': 'Online Banking (FPX)',
      'subtitle': 'Maybank2u, CIMB Clicks, Bank Islam, RHB',
      'icon': Icons.account_balance_outlined,
    },
    {
      'id': 'Pay at Counter',
      'title': 'Pay at Counter',
      'subtitle': 'Cash / Card upon self-pickup at COOP UTHM',
      'icon': Icons.point_of_sale,
    },
  ];

  String get _formattedPaymentLabel {
    if (_selectedPayment == 'E-Wallet') {
      return 'E-Wallet ($_selectedEwallet)';
    } else if (_selectedPayment == 'Online Banking (FPX)') {
      return 'FPX ($_selectedBank)';
    }
    return _selectedPayment;
  }

  Future<void> _processCheckout() async {
    setState(() => _isProcessing = true);
    try {
      final orderId = await coopState.completeCheckout(
        paymentMethod: _formattedPaymentLabel,
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 52),
          title: const Text('Order Confirmed!'),
          content: Text(
            'Order ID: $orderId\n'
            'Payment: $_formattedPaymentLabel\n\n'
            'You can view your digital receipt in the Orders tab.',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: coopState,
      builder: (context, _) {
        final entries = coopState.cart.entries.toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(coopState.tr('cart')),
          ),
          body: entries.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Your cart is empty'),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...entries.map((entry) {
                      final product = coopState.products
                          .where((p) => p.id == entry.key)
                          .firstOrNull;
                      if (product == null) return const SizedBox.shrink();
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'RM ${product.price.toStringAsFixed(2)} each',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => coopState.updateCartQty(
                                  product.id,
                                  entry.value - 1,
                                ),
                              ),
                              Text(
                                '${entry.value}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: entry.value < product.stock
                                    ? () => coopState.updateCartQty(
                                          product.id,
                                          entry.value + 1,
                                        )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Text(
                      coopState.tr('payment_method'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ..._paymentOptions.map((opt) {
                      final isSelected = _selectedPayment == opt['id'];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFFE60000)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              value: opt['id'],
                              groupValue: _selectedPayment,
                              activeColor: const Color(0xFFE60000),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedPayment = val);
                                }
                              },
                              secondary: Icon(opt['icon']),
                              title: Text(
                                opt['title'],
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(opt['subtitle']),
                            ),
                            if (isSelected && opt['id'] == 'E-Wallet')
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedEwallet,
                                  decoration: const InputDecoration(
                                    labelText: 'Choose E-Wallet Provider',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Touch \'n Go eWallet',
                                      child: Text('Touch \'n Go eWallet'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'GrabPay',
                                      child: Text('GrabPay'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'ShopeePay',
                                      child: Text('ShopeePay'),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _selectedEwallet = v);
                                    }
                                  },
                                ),
                              ),
                            if (isSelected && opt['id'] == 'Online Banking (FPX)')
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedBank,
                                  decoration: const InputDecoration(
                                    labelText: 'Select FPX Bank',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Maybank2u',
                                      child: Text('Maybank2u'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'CIMB Clicks',
                                      child: Text('CIMB Clicks'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Bank Islam',
                                      child: Text('Bank Islam'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'RHB Now',
                                      child: Text('RHB Now'),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _selectedBank = v);
                                    }
                                  },
                                ),
                              ),
                            if (isSelected && opt['id'] == 'QR Code')
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.pink.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.pink.shade200),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'DuitNow QR — KOPERASI UTHM BERHAD',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pink,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.qr_code_2,
                                          size: 110,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Amount: RM ${coopState.cartSubtotal.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'RM ${coopState.cartSubtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE60000),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _isProcessing ? null : _processCheckout,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE60000),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              coopState.tr('place_order'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}