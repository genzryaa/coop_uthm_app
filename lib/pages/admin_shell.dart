import 'package:flutter/material.dart';
import '../data/coop_data.dart';
import 'admin_dashboard_page.dart';
import 'admin_inventory_page.dart';
import 'admin_sales_page.dart';
import 'profile_page.dart';

class AdminNavigationShell extends StatefulWidget {
  const AdminNavigationShell({super.key});

  @override
  State<AdminNavigationShell> createState() => _AdminNavigationShellState();
}

class _AdminNavigationShellState extends State<AdminNavigationShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const AdminDashboardPage(),
      const AdminInventoryPage(),
      const AdminSalesPage(),
      const UserProfilePage(isAdmin: true),
    ];

    return ListenableBuilder(
      listenable: coopState,
      builder: (context, _) {
        return Scaffold(
          body: pages[_selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) =>
                setState(() => _selectedIndex = idx),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: coopState.tr('dashboard'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.inventory_2_outlined),
                selectedIcon: const Icon(Icons.inventory_2),
                label: coopState.tr('inventory'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.point_of_sale_outlined),
                selectedIcon: const Icon(Icons.point_of_sale),
                label: coopState.tr('sales'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: coopState.tr('profile'),
              ),
            ],
          ),
        );
      },
    );
  }
}