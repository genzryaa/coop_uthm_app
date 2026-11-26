import 'dart:async';
import 'package:flutter/material.dart';
import '../data/coop_data.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _chartRange = 'Day'; // 'Day', 'Week', 'Month'
  late DateTime _now;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  String get _formattedDateTime {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dayName = days[_now.weekday - 1];
    final monthName = months[_now.month - 1];
    final hh = _now.hour.toString().padLeft(2, '0');
    final mm = _now.minute.toString().padLeft(2, '0');
    final ss = _now.second.toString().padLeft(2, '0');
    return '$dayName, ${_now.day} $monthName ${_now.year}  •  $hh:$mm:$ss';
  }

  List> _buildChartBuckets() {
    final now = DateTime.now();
    if (_chartRange == 'Day') {
      // Last 7 days
      return List.generate(7, (i) {
        final target = now.subtract(Duration(days: 6 - i));
        final total = coopState.orders
            .where((o) =>
                o.date.year == target.year &&
                o.date.month == target.month &&
                o.date.day == target.day)
            .fold(0.0, (sum, o) => sum + o.total);
        return {
          'label': '${target.day}/${target.month}',
          'value': total,
        };
      });
    } else if (_chartRange == 'Week') {
      // Last 4 weeks
      return List.generate(4, (i) {
        final weekIndex = 3 - i;
        final end = now.subtract(Duration(days: weekIndex * 7));
        final start = end.subtract(const Duration(days: 6));
        final total = coopState.orders
            .where((o) =>
                o.date.isAfter(start.subtract(const Duration(days: 1))) &&
                o.date.isBefore(end.add(const Duration(days: 1))))
            .fold(0.0, (sum, o) => sum + o.total);
        return {
          'label': 'W${i + 1}',
          'value': total,
        };
      });
    } else {
      // Last 6 months
      const mNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return List.generate(6, (i) {
        final monthOffset = 5 - i;
        final target = DateTime(now.year, now.month - monthOffset, 1);
        final total = coopState.orders
            .where((o) =>
                o.date.year == target.year && o.date.month == target.month)
            .fold(0.0, (sum, o) => sum + o.total);
        return {
          'label': mNames[target.month - 1],
          'value': total,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: coopState,
      builder: (context, _) {
        final totalRevenue =
            coopState.orders.fold(0.0, (sum, o) => sum + o.total);
        final totalExpenses =
            coopState.expenses.fold(0.0, (sum, e) => sum + e.amount);
        final netProfit = totalRevenue - totalExpenses;
        final lowStockProducts =
            coopState.products.where((p) => p.stock <= 5).toList();
        final buckets = _buildChartBuckets();
        final maxVal = buckets.fold<double>(
          10.0,
          (max, b) => (b['value'] as double) > max ? (b['value'] as double) : max,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('COOP Staff Dashboard'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Live Date & Time Banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE60000).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE60000).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFFE60000)),
                    const SizedBox(width: 10),
                    Text(
                      _formattedDateTime,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Financial Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Revenue',
                      value: 'RM ${totalRevenue.toStringAsFixed(2)}',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      title: 'Expenses',
                      value: 'RM ${totalExpenses.toStringAsFixed(2)}',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      title: 'Net Profit',
                      value: 'RM ${netProfit.toStringAsFixed(2)}',
                      color: netProfit >= 0 ? Colors.blue : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Sales Statistics Graph (Day / Week / Month)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              coopState.tr('sales_stats'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SegmentedButton<String>(
                            showSelectedIcon: false,
                            segments: [
                              ButtonSegment(
                                value: 'Day',
                                label: Text(coopState.tr('day')),
                              ),
                              ButtonSegment(
                                value: 'Week',
                                label: Text(coopState.tr('week')),
                              ),
                              ButtonSegment(
                                value: 'Month',
                                label: Text(coopState.tr('month')),
                              ),
                            ],
                            selected: {_chartRange},
                            onSelectionChanged: (val) =>
                                setState(() => _chartRange = val.first),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 170,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: buckets.map((b) {
                            final val = b['value'] as double;
                            final barHeight = (val / maxVal) * 115;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  val > 0 ? val.toStringAsFixed(0) : '0',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 26,
                                  height: barHeight < 6 ? 6 : barHeight,
                                  decoration: BoxDecoration(
                                    color: val > 0
                                        ? const Color(0xFFE60000)
                                        : Colors.grey.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  b['label'],
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Low Stock Alerts
              Text(
                'Low-Stock Alerts (${lowStockProducts.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              if (lowStockProducts.isEmpty)
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('All 40 COOP retail SKUs are well-stocked.'),
                  ),
                )
              else
                ...lowStockProducts.map(
                  (p) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber, color: Colors.red),
                      title: Text(p.name),
                      subtitle: Text('Remaining stock: ${p.stock}'),
                      trailing: FilledButton(
                        onPressed: () => coopState.restockProduct(p.id, 20),
                        child: const Text('+20 Stock'),
                      ),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}