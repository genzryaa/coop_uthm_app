import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String? imageUrl;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.createdAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Product',
      category: data['category'] ?? 'General',
      price: (data['price'] ?? 0.0).toDouble(),
      stock: (data['stock'] ?? 0).toInt(),
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}