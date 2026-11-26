import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  int stock;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'Essentials',
      price: (map['price'] ?? 0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'stock': stock,
      };
}

class OrderRecord {
  final String orderId;
  final String buyerName;
  final String buyerEmail;
  final DateTime date;
  final double total;
  final int itemCount;
  final String paymentMethod;
  final bool isPickedUp;
  final List<String> itemsSummary;

  OrderRecord({
    required this.orderId,
    required this.buyerName,
    this.buyerEmail = '',
    required this.date,
    required this.total,
    required this.itemCount,
    required this.paymentMethod,
    required this.isPickedUp,
    this.itemsSummary = const [],
  });

  factory OrderRecord.fromMap(Map<String, dynamic> map) {
    return OrderRecord(
      orderId: map['orderId'] ?? '',
      buyerName: map['buyerName'] ?? 'UTHM Student',
      buyerEmail: map['buyerEmail'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      total: (map['total'] ?? 0).toDouble(),
      itemCount: (map['itemCount'] ?? 1).toInt(),
      paymentMethod: map['paymentMethod'] ?? 'Pay at Counter',
      isPickedUp: map['isPickedUp'] ?? false,
      itemsSummary: List<String>.from(map['itemsSummary'] ?? []),
    );
  }
}

class ExpenseRecord {
  final String id;
  final String title;
  final double amount;
  final DateTime date;

  ExpenseRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  });

  factory ExpenseRecord.fromMap(Map<String, dynamic> map) {
    return ExpenseRecord(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class CoopStoreState extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Product> products = [];
  List<OrderRecord> orders = [];
  List<ExpenseRecord> expenses = [];
  final Map<String, int> cart = {};

  // User profile state
  String currentUserName = 'UTHM Buyer';
  String currentUserEmail = '';
  String currentUserRole = 'buyer';

  // Feature 2: Theme & Dual Language ('en' or 'ms')
  ThemeMode themeMode = ThemeMode.system;
  String languageCode = 'en';

  // Feature 3: Search History
  final List<String> recentSearches = [];

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'catalog': 'Catalog',
      'orders': 'Orders',
      'cart': 'Cart',
      'profile': 'Profile',
      'dashboard': 'Dashboard',
      'inventory': 'Inventory',
      'sales': 'Sales',
      'retail_store': 'Retail Store',
      'search_hint': 'Search COOP products...',
      'recent_searches': 'Recent Searches',
      'clear': 'Clear',
      'checkout': 'Checkout',
      'payment_method': 'Select Payment Method',
      'place_order': 'Confirm & Place Order',
      'order_history': 'Order History & Receipts',
      'view_receipt': 'View Digital Receipt',
      'appearance': 'Appearance (Theme)',
      'system_theme': 'System Default',
      'light_theme': 'Light Mode',
      'dark_theme': 'Dark Mode',
      'language': 'Language / Bahasa',
      'logout': 'Sign Out',
      'sales_stats': 'Sales & Revenue Statistics',
      'day': 'Day',
      'week': 'Week',
      'month': 'Month',
    },
    'ms': {
      'catalog': 'Katalog',
      'orders': 'Pesanan',
      'cart': 'Troli',
      'profile': 'Profil',
      'dashboard': 'Papan Pemuka',
      'inventory': 'Inventori',
      'sales': 'Jualan',
      'retail_store': 'Kedai Runcit',
      'search_hint': 'Cari produk COOP...',
      'recent_searches': 'Carian Terkini',
      'clear': 'Padam',
      'checkout': 'Pembayaran',
      'payment_method': 'Pilih Kaedah Pembayaran',
      'place_order': 'Sahkan & Buat Pesanan',
      'order_history': 'Sejarah Pesanan & Resit',
      'view_receipt': 'Lihat Resit Digital',
      'appearance': 'Paparan (Tema)',
      'system_theme': 'Ikut Sistem',
      'light_theme': 'Mod Cerah',
      'dark_theme': 'Mod Gelap',
      'language': 'Bahasa / Language',
      'logout': 'Log Keluar',
      'sales_stats': 'Statistik Jualan & Hasil',
      'day': 'Hari',
      'week': 'Minggu',
      'month': 'Bulan',
    },
  };

  String tr(String key) => _strings[languageCode]?[key] ?? key;

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  void setLanguage(String code) {
    languageCode = code;
    notifyListeners();
  }

  void addSearchHistory(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    recentSearches.removeWhere((item) => item.toLowerCase() == q.toLowerCase());
    recentSearches.insert(0, q);
    if (recentSearches.length > 8) {
      recentSearches.removeLast();
    }
    notifyListeners();
  }

  void removeSearchHistoryItem(String query) {
    recentSearches.remove(query);
    notifyListeners();
  }

  void clearSearchHistory() {
    recentSearches.clear();
    notifyListeners();
  }

  void setUserProfile({
    required String name,
    required String email,
    required String role,
  }) {
    currentUserName = name;
    currentUserEmail = email;
    currentUserRole = role;
    notifyListeners();
  }

  int get totalCartCount => cart.values.fold(0, (a, b) => a + b);

  double get cartSubtotal {
    double sum = 0;
    cart.forEach((productId, qty) {
      final prod = products.where((p) => p.id == productId).firstOrNull;
      if (prod != null) sum += prod.price * qty;
    });
    return sum;
  }

  void addToCart(Product product) {
    final current = cart[product.id] ?? 0;
    if (current < product.stock) {
      cart[product.id] = current + 1;
      notifyListeners();
    }
  }

  void updateCartQty(String productId, int qty) {
    if (qty <= 0) {
      cart.remove(productId);
    } else {
      cart[productId] = qty;
    }
    notifyListeners();
  }

  Future<void> initFirestoreData() async {
    _db.collection('products').snapshots().listen((snap) {
      products = snap.docs.map((d) => Product.fromMap(d.data())).toList()
        ..sort((a, b) => a.id.compareTo(b.id));
      notifyListeners();
    });

    _db
        .collection('orders')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
      orders = snap.docs.map((d) => OrderRecord.fromMap(d.data())).toList();
      notifyListeners();
    });

    _db
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
      expenses = snap.docs.map((d) => ExpenseRecord.fromMap(d.data())).toList();
      notifyListeners();
    });
  }

  Future<String> completeCheckout({required String paymentMethod}) async {
    final orderId =
        'COOP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final total = cartSubtotal;
    final count = totalCartCount;
    final List<String> summary = [];

    final batch = _db.batch();
    cart.forEach((productId, qty) {
      final prod = products.where((p) => p.id == productId).firstOrNull;
      if (prod != null) {
        summary.add('${prod.name} x$qty (RM ${(prod.price * qty).toStringAsFixed(2)})');
        final newStock = (prod.stock - qty).clamp(0, 9999);
        batch.update(_db.collection('products').doc(prod.id), {'stock': newStock});
      }
    });

    batch.set(_db.collection('orders').doc(orderId), {
      'orderId': orderId,
      'buyerName': currentUserName,
      'buyerEmail': currentUserEmail,
      'date': Timestamp.now(),
      'total': total,
      'itemCount': count,
      'paymentMethod': paymentMethod,
      'isPickedUp': false,
      'itemsSummary': summary,
    });

    await batch.commit();
    cart.clear();
    notifyListeners();
    return orderId;
  }

  Future<void> restockProduct(String productId, int addQty) async {
    final prod = products.where((p) => p.id == productId).firstOrNull;
    if (prod == null) return;
    await _db
        .collection('products')
        .doc(productId)
        .update({'stock': prod.stock + addQty});
  }

  Future<void> addProduct(Product product) async {
    await _db.collection('products').doc(product.id).set(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  Future<void> addExpense(String title, double amount) async {
    final id = 'EXP-${DateTime.now().millisecondsSinceEpoch}';
    await _db.collection('expenses').doc(id).set({
      'id': id,
      'title': title,
      'amount': amount,
      'date': Timestamp.now(),
    });
  }

  Future<void> markOrderPickedUp(String orderId) async {
    await _db
        .collection('orders')
        .doc(orderId)
        .update({'isPickedUp': true});
  }
}

final CoopStoreState coopState = CoopStoreState();