import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  const PaymentPage({super.key, required this.totalAmount});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedMethod = 'Card (Stripe)';
  String _selectedBank = 'Maybank2u';
  String _selectedWallet = 'Touch \'n Go eWallet';

  final List<String> _methods = [
    'Card (Stripe)',
    'Online Banking (FPX)',
    'E-Wallet',
    'DuitNow QR',
    'Pay at Counter',
  ];

  void _processPayment() {
    // 1. If 'Card (Stripe)': invoke Stripe.instance.presentPaymentSheet()
    // 2. If 'FPX' / 'E-Wallet' / 'QR' / 'Counter': generate mock payment token
    final mockToken = 'TXN-${DateTime.now().millisecondsSinceEpoch}';
    
    // 3. Save Order to Firestore with status: 'Pending' (or 'Completed')
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Order Placed!'),
        content: Text('Method: $_selectedMethod\nRef: $mockToken\nStatus: Pending'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to Orders tab
            },
            child: const Text('View Order'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout & Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Total Payable'),
                trailing: Text(
                  'RM ${widget.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  ..._methods.map(
                    (method) => RadioListTile<String>(
                      title: Text(method),
                      value: method,
                      groupValue: _selectedMethod,
                      onChanged: (val) => setState(() => _selectedMethod = val!),
                    ),
                  ),
                  const Divider(),
                  if (_selectedMethod == 'Online Banking (FPX)')
                    DropdownButtonFormField<String>(
                      value: _selectedBank,
                      decoration: const InputDecoration(labelText: 'Select Bank'),
                      items: ['Maybank2u', 'CIMB Clicks', 'Bank Islam', 'RHB Now']
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedBank = val!),
                    ),
                  if (_selectedMethod == 'E-Wallet')
                    DropdownButtonFormField<String>(
                      value: _selectedWallet,
                      decoration: const InputDecoration(labelText: 'Select E-Wallet'),
                      items: ['Touch \'n Go eWallet', 'GrabPay', 'ShopeePay']
                          .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedWallet = val!),
                    ),
                  if (_selectedMethod == 'DuitNow QR')
                    const Column(
                      children: [
                        Icon(Icons.qr_code_2, size: 160),
                        Text('Scan DuitNow QR (Koperasi UTHM Berhad)'),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _processPayment,
                child: const Text('Confirm & Pay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}