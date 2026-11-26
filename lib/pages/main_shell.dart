import 'package:flutter/material.dart';
import '../data/coop_data.dart';
import 'home_page.dart';
import 'order_history_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const BuyerHomePage(),
      const OrderHistoryPage(),
      const CartCheckoutPage(),
      const UserProfilePage(isAdmin: false),
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
                icon: const Icon(Icons.store_outlined),
                selectedIcon: const Icon(Icons.store),
                label: coopState.tr('catalog'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(Icons.receipt_long),
                label: coopState.tr('orders'),
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: coopState.totalCartCount > 0,
                  label: Text('${coopState.totalCartCount}'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                selectedIcon: const Icon(Icons.shopping_cart),
                label: coopState.tr('cart'),
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