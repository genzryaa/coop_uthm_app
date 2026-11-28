import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String category;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'category': category,
        'quantity': quantity,
      };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        price: (map['price'] ?? 0.0).toDouble(),
        category: map['category'] ?? '',
        quantity: map['quantity'] ?? 1,
      );
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  CartProvider() {
    _loadCartFromLocal();
  }

  Map<String, CartItem> get items => {..._items};

  int get totalItems =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  Future<void> _saveCartToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _items.map((key, item) => MapEntry(key, item.toMap())),
    );
    await prefs.setString('cached_cart', encoded);
  }

  Future<void> _loadCartFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_cart');
    if (cachedData != null) {
      final Map<String, dynamic> decoded = jsonDecode(cachedData);
      _items.clear();
      decoded.forEach((key, value) {
        _items[key] = CartItem.fromMap(value);
      });
      notifyListeners();
    }
  }

  void addItem({
    required String id,
    required String name,
    required double price,
    required String category,
  }) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity += 1;
    } else {
      _items[id] = CartItem(
        id: id,
        name: name,
        price: price,
        category: category,
      );
    }
    notifyListeners();
    _saveCartToLocal();
  }

  void updateQuantity(String id, int delta) {
    if (!_items.containsKey(id)) return;
    _items[id]!.quantity += delta;
    if (_items[id]!.quantity <= 0) {
      _items.remove(id);
    }
    notifyListeners();
    _saveCartToLocal();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
    _saveCartToLocal();
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_cart');
  }
}