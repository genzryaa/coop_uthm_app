import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_locale_provider.dart';
import 'cart_page.dart';
import 'catalog_page.dart';
import 'order_page.dart';
import 'profile_page.dart';

class CustomerMainPage extends StatefulWidget {
  const CustomerMainPage({super.key});

  @override
  State<CustomerMainPage> createState() => _CustomerMainPageState();
}

class _CustomerMainPageState extends State<CustomerMainPage> {
  int _currentIndex = 0;

  // Keeps all 4 pages alive when switching tabs (preserves search/scroll state)
  final List<Widget> _pages = const [
    CatalogPage(),
    CartPage(),
    OrderPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<ThemeLocaleProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final isBm = localeProvider.locale.languageCode == 'ms';

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          // 1. Catalog Tab
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront),
            label: isBm ? 'Katalog' : 'Catalog',
          ),

          // 2. Cart Tab (with live item badge)
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartProvider.totalItems > 0,
              label: Text('${cartProvider.totalItems}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cartProvider.totalItems > 0,
              label: Text('${cartProvider.totalItems}'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: isBm ? 'Troli' : 'Cart',
          ),

          // 3. Orders Tab
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: isBm ? 'Pesanan' : 'Orders',
          ),

          // 4. Profile Tab
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: isBm ? 'Profil' : 'Profile',
          ),
        ],
      ),
    );
  }
}