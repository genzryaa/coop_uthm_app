import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/coop_data.dart';
import 'login_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  void _showAddExpenseDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record Store Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Expense Description (e.g. Stock Restock)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (RM)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final amt = double.tryParse(amountCtrl.text) ?? 0.0;
              if (titleCtrl.text.isNotEmpty && amt > 0) {
                await coopState.addExpense(titleCtrl.text, amt);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save Expense'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profit = coopState.netProfit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('COOP Staff Financial Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Revenue',
                  value: 'RM ${coopState.totalRevenue.toStringAsFixed(2)}',
                  color: Colors.green,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'Expenses',
                  value: 'RM ${coopState.totalExpenses.toStringAsFixed(2)}',
                  color: Colors.orange,
                  icon: Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MetricCard(
            title: 'Net Profit / Loss',
            value: 'RM ${profit.toStringAsFixed(2)}',
            color: profit >= 0 ? const Color(0xFF0D47A1) : Colors.red,
            icon: Icons.account_balance_wallet,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 6),
              Text(
                'Low-Stock Alerts (${coopState.lowStockProducts.length} items ≤ 5)',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (coopState.lowStockProducts.isEmpty)
            const Card(
              child: ListTile(title: Text('All retail items are well stocked.')),
            )
          else
            ...coopState.lowStockProducts.map(
              (item) => Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: Icon(item.icon, color: Colors.red),
                  title: Text(item.name),
                  subtitle: Text(
                      'Category: ${item.category} • Only ${item.stock} left'),
                  trailing: FilledButton.tonal(
                    onPressed: () => coopState.restockProduct(item, 20),
                    child: const Text('+20 Stock'),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Operational Expenses Log',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...coopState.expenses.map(
            (exp) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.receipt)),
                title: Text(exp.title),
                trailing: Text(
                  '- RM ${exp.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}