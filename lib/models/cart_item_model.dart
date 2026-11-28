class CartItemModel {
  final String id;
  final String name;
  final double price;
  final String category;
  int quantity;

  CartItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.quantity = 1,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      quantity: (map['quantity'] ?? 1).toInt(),
    );
  }
}