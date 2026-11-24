import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  int stock;
  final IconData icon;
  final Color color;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'stock': stock,
      };

  factory Product.fromMap(Map<String, dynamic> map) {
    final cat = map['category'] ?? 'Snacks';
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: cat,
      price: (map['price'] ?? 0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
      icon: _iconForCategory(cat),
      color: _colorForCategory(cat),
    );
  }

  static IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'Beverages':
        return Icons.local_drink;
      case 'Stationery':
        return Icons.edit;
      case 'Essentials':
        return Icons.shopping_bag;
      default:
        return Icons.fastfood;
    }
  }

  static Color _colorForCategory(String cat) {
    switch (cat) {
      case 'Beverages':
        return Colors.blue;
      case 'Stationery':
        return Colors.indigo;
      case 'Essentials':
        return Colors.teal;
      default:
        return Colors.orange;
    }
  }
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class OrderRecord {
  final String orderId;
  final String buyerName;
  final DateTime date;
  final double total;
  final int itemCount;
  final String paymentMethod;
  bool isPickedUp;

  OrderRecord({
    required this.orderId,
    required this.buyerName,
    required this.date,
    required this.total,
    required this.itemCount,
    required this.paymentMethod,
    this.isPickedUp = false,
  });

  Map<String, dynamic> toMap() => {
        'orderId': orderId,
        'buyerName': buyerName,
        'date': date.toIso8601String(),
        'total': total,
        'itemCount': itemCount,
        'paymentMethod': paymentMethod,
        'isPickedUp': isPickedUp,
      };

  factory OrderRecord.fromMap(Map<String, dynamic> map) => OrderRecord(
        orderId: map['orderId'] ?? '',
        buyerName: map['buyerName'] ?? '',
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        total: (map['total'] ?? 0).toDouble(),
        itemCount: (map['itemCount'] ?? 0).toInt(),
        paymentMethod: map['paymentMethod'] ?? 'Stripe Sandbox',
        isPickedUp: map['isPickedUp'] ?? false,
      );
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory ExpenseRecord.fromMap(Map<String, dynamic> map) => ExpenseRecord(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        amount: (map['amount'] ?? 0).toDouble(),
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      );
}

class CoopStoreState extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  String currentUserName = 'Student Buyer';
  String currentUserEmail = '';

  final List<String> categories = [
    'All',
    'Snacks',
    'Beverages',
    'Stationery',
    'Essentials',
  ];

  List<Product> products = [];
  final List<CartItem> cart = [];
  List<OrderRecord> orders = [];
  List<ExpenseRecord> expenses = [];

  // 40 Initial COOP UTHM Retail Items (10 per category, strictly retail store)
  final List<Product> _default40Products = [
    // 1. SNACKS (10 Items)
    Product(id: 'SN01', name: 'Mister Potato Original 75g', category: 'Snacks', price: 3.50, stock: 24, icon: Icons.fastfood, color: Colors.orange),
    Product(id: 'SN02', name: 'Twisties BBQ Curry 60g', category: 'Snacks', price: 2.20, stock: 30, icon: Icons.fastfood, color: Colors.deepOrange),
    Product(id: 'SN03', name: 'Oreo Vanilla Cream Pack', category: 'Snacks', price: 3.80, stock: 18, icon: Icons.cookie, color: Colors.indigo),
    Product(id: 'SN04', name: 'Hup Seng Cream Crackers', category: 'Snacks', price: 4.50, stock: 4, icon: Icons.bakery_dining, color: Colors.amber),
    Product(id: 'SN05', name: 'LexUS Chocolate Sandwich', category: 'Snacks', price: 4.20, stock: 20, icon: Icons.cookie, color: Colors.brown),
    Product(id: 'SN06', name: 'Maggi Hot Cup Kari', category: 'Snacks', price: 2.50, stock: 40, icon: Icons.ramen_dining, color: Colors.red),
    Product(id: 'SN07', name: 'Maggi Hot Cup Tom Yam', category: 'Snacks', price: 2.50, stock: 35, icon: Icons.ramen_dining, color: Colors.redAccent),
    Product(id: 'SN08', name: 'Cadbury Dairy Milk 40g', category: 'Snacks', price: 3.90, stock: 22, icon: Icons.icecream, color: Colors.purple),
    Product(id: 'SN09', name: 'Gardenia Twiggies Choc', category: 'Snacks', price: 2.00, stock: 16, icon: Icons.bakery_dining, color: Colors.brown),
    Product(id: 'SN10', name: 'Apollo Layer Cake Pandan', category: 'Snacks', price: 1.50, stock: 50, icon: Icons.cake, color: Colors.green),

    // 2. PACKAGED BEVERAGES (10 Items)
    Product(id: 'BV01', name: 'Spritzer Mineral Water 600ml', category: 'Beverages', price: 1.20, stock: 60, icon: Icons.water_drop, color: Colors.lightBlue),
    Product(id: 'BV02', name: 'Spritzer Mineral Water 1.5L', category: 'Beverages', price: 2.40, stock: 30, icon: Icons.water_drop, color: Colors.blue),
    Product(id: 'BV03', name: '100PLUS Original Can 325ml', category: 'Beverages', price: 2.30, stock: 45, icon: Icons.local_drink, color: Colors.teal),
    Product(id: 'BV04', name: 'Milo UHT Packet 200ml', category: 'Beverages', price: 2.20, stock: 48, icon: Icons.local_drink, color: Colors.green),
    Product(id: 'BV05', name: 'Dutch Lady Full Cream 200ml', category: 'Beverages', price: 2.50, stock: 25, icon: Icons.local_drink, color: Colors.blueAccent),
    Product(id: 'BV06', name: 'Nescafe Original Can 240ml', category: 'Beverages', price: 2.80, stock: 32, icon: Icons.coffee, color: Colors.brown),
    Product(id: 'BV07', name: 'Yeos Chrysanthemum Tea 250ml', category: 'Beverages', price: 1.60, stock: 36, icon: Icons.emoji_food_beverage, color: Colors.amber),
    Product(id: 'BV08', name: 'Ribena Blackcurrant Packet', category: 'Beverages', price: 2.40, stock: 3, icon: Icons.local_drink, color: Colors.deepPurple),
    Product(id: 'BV09', name: 'Revive Isotonic Bottle 500ml', category: 'Beverages', price: 3.00, stock: 28, icon: Icons.local_drink, color: Colors.cyan),
    Product(id: 'BV10', name: 'Wonda Kopi Tarik Can 240ml', category: 'Beverages', price: 2.90, stock: 19, icon: Icons.coffee, color: Colors.orange),

    // 3. STATIONERY (10 Items)
    Product(id: 'ST01', name: 'UTHM A4 Test Pad (80 Sheets)', category: 'Stationery', price: 3.50, stock: 50, icon: Icons.description, color: Colors.blueGrey),
    Product(id: 'ST02', name: 'Faber-Castell Ball Pen (Blue)', category: 'Stationery', price: 1.30, stock: 80, icon: Icons.edit, color: Colors.blue),
    Product(id: 'ST03', name: 'Faber-Castell Ball Pen (Black)', category: 'Stationery', price: 1.30, stock: 75, icon: Icons.edit, color: Colors.black87),
    Product(id: 'ST04', name: 'Pilot G2 Gel Pen 0.5mm', category: 'Stationery', price: 4.50, stock: 40, icon: Icons.create, color: Colors.indigo),
    Product(id: 'ST05', name: 'Stabilo Boss Highlighter Yellow', category: 'Stationery', price: 3.80, stock: 30, icon: Icons.highlight, color: Colors.yellow.shade800),
    Product(id: 'ST06', name: '2B Exam Pencil Set (4 pcs)', category: 'Stationery', price: 2.80, stock: 45, icon: Icons.edit_outlined, color: Colors.green),
    Product(id: 'ST07', name: 'Faber-Castell Dust-Free Eraser', category: 'Stationery', price: 1.20, stock: 60, icon: Icons.cleaning_services, color: Colors.grey),
    Product(id: 'ST08', name: 'Liquid Correction Tape 5mm', category: 'Stationery', price: 3.20, stock: 25, icon: Icons.format_paint, color: Colors.lightBlue),
    Product(id: 'ST09', name: 'Clear Plastic L-Folder A4', category: 'Stationery', price: 1.00, stock: 90, icon: Icons.folder_open, color: Colors.teal),
    Product(id: 'ST10', name: 'Mini Stapler + Box Staples', category: 'Stationery', price: 5.50, stock: 5, icon: Icons.attach_file, color: Colors.red),

    // 4. DAILY ESSENTIALS (10 Items)
    Product(id: 'ES01', name: 'Premier Pocket Tissue (4 Packs)', category: 'Essentials', price: 2.80, stock: 42, icon: Icons.layers, color: Colors.blue),
    Product(id: 'ES02', name: 'Dettol Wet Wipes (10 Sheets)', category: 'Essentials', price: 3.50, stock: 30, icon: Icons.clean_hands, color: Colors.green),
    Product(id: 'ES03', name: 'Colgate Toothpaste Travel 40g', category: 'Essentials', price: 3.20, stock: 22, icon: Icons.health_and_safety, color: Colors.red),
    Product(id: 'ES04', name: 'Soft Bristle Toothbrush', category: 'Essentials', price: 2.50, stock: 25, icon: Icons.brush, color: Colors.cyan),
    Product(id: 'ES05', name: 'Lifebuoy Bar Soap 75g', category: 'Essentials', price: 2.20, stock: 35, icon: Icons.soap, color: Colors.redAccent),
    Product(id: 'ES06', name: 'Breeze Detergent Sachet 150g', category: 'Essentials', price: 2.00, stock: 40, icon: Icons.local_laundry_service, color: Colors.indigo),
    Product(id: 'ES07', name: '3-Ply Face Mask Pack (10 pcs)', category: 'Essentials', price: 3.00, stock: 50, icon: Icons.masks, color: Colors.teal),
    Product(id: 'ES08', name: 'Panadol Actifast Strip (10 Tabs)', category: 'Essentials', price: 6.50, stock: 15, icon: Icons.medical_services, color: Colors.blueAccent),
    Product(id: 'ES09', name: 'Hand Sanitizer Pocket 50ml', category: 'Essentials', price: 4.50, stock: 28, icon: Icons.sanitizer, color: Colors.lightGreen),
    Product(id: 'ES10', name: 'Foldable Campus Umbrella', category: 'Essentials', price: 14.90, stock: 12, icon: Icons.umbrella, color: Colors.deepPurple),
  ];

  // Auto-seed 40 items if Firestore is empty & listen to live cloud updates
  Future<void> initFirestoreData() async {
    final prodSnap = await _db.collection('products').get();
    if (prodSnap.docs.isEmpty) {
      for (final p in _default40Products) {
        await _db.collection('products').doc(p.id).set(p.toMap());
      }
    }

    _db.collection('products').snapshots().listen((snap) {
      products = snap.docs.map((d) => Product.fromMap(d.data())).toList();
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

  int get totalCartCount => cart.fold(0, (sum, item) => sum + item.quantity);
  double get totalCartAmount =>
      cart.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  double get totalRevenue =>
      orders.fold(0.0, (sum, order) => sum + order.total);
  double get totalExpenses =>
      expenses.fold(0.0, (sum, exp) => sum + exp.amount);
  double get netProfit => totalRevenue - totalExpenses;
  List<Product> get lowStockProducts =>
      products.where((p) => p.stock <= 5).toList();

  void addToCart(Product product) {
    final index = cart.indexWhere((c) => c.product.id == product.id);
    if (index >= 0) {
      cart[index].quantity++;
    } else {
      cart.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void updateQuantity(Product product, int delta) {
    final index = cart.indexWhere((c) => c.product.id == product.id);
    if (index >= 0) {
      cart[index].quantity += delta;
      if (cart[index].quantity <= 0) {
        cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  Future<OrderRecord> completeStripeMockCheckout() async {
    for (var item in cart) {
      final newStock = (item.product.stock - item.quantity).clamp(0, 9999);
      await _db
          .collection('products')
          .doc(item.product.id)
          .update({'stock': newStock});
    }

    final orderId = 'COOP-${1000 + DateTime.now().millisecond * 8}';
    final newOrder = OrderRecord(
      orderId: orderId,
      buyerName: currentUserName,
      date: DateTime.now(),
      total: totalCartAmount,
      itemCount: totalCartCount,
      paymentMethod: 'Stripe Sandbox (•••• 4242)',
      isPickedUp: false,
    );

    await _db.collection('orders').doc(orderId).set(newOrder.toMap());
    cart.clear();
    notifyListeners();
    return newOrder;
  }

  Future<void> restockProduct(Product product, int addQty) async {
    await _db
        .collection('products')
        .doc(product.id)
        .update({'stock': product.stock + addQty});
  }

  Future<void> addNewProduct(
      String name, String category, double price, int stock) async {
    final id = 'SKU-${DateTime.now().millisecondsSinceEpoch}';
    final p = Product(
      id: id,
      name: name,
      category: category,
      price: price,
      stock: stock,
      icon: Product._iconForCategory(category),
      color: Product._colorForCategory(category),
    );
    await _db.collection('products').doc(id).set(p.toMap());
  }

  Future<void> deleteProduct(Product product) async {
    await _db.collection('products').doc(product.id).delete();
  }

  Future<void> addExpense(String title, double amount) async {
    final id = 'EXP-${DateTime.now().millisecondsSinceEpoch}';
    final exp = ExpenseRecord(
      id: id,
      title: title,
      amount: amount,
      date: DateTime.now(),
    );
    await _db.collection('expenses').doc(id).set(exp.toMap());
  }

  Future<void> toggleOrderPickup(OrderRecord order) async {
    await _db
        .collection('orders')
        .doc(order.orderId)
        .update({'isPickedUp': !order.isPickedUp});
  }
}

final coopState = CoopStoreState();