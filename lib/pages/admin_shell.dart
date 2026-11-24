import 'package:flutter/material.dart';
import 'admin_dashboard_page.dart';
import 'admin_inventory_page.dart';
import 'admin_sales_page.dart';

class AdminNavigationShell extends StatefulWidget {
  const AdminNavigationShell({super.key});

  @override
  State<AdminNavigationShell> createState() => _AdminNavigationShellState();
}

class _AdminNavigationShellState extends State<AdminNavigationShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final adminPages = [
      const AdminDashboardPage(),
      const AdminInventoryPage(),
      const AdminSalesPage(),
    ];

    return Scaffold(
      body: adminPages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Sales',
          ),
        ],
      ),
    );
  }
}