import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final String userEmail;
  final List<CartItemModel> items;
  final double totalAmount;
  final String paymentMethod;
  final String paymentRef;
  final String status; // 'Pending', 'Completed', 'Cancelled'
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentRef,
    required this.status,
    this.createdAt,
  });

  bool get isCompleted => status.toLowerCase() == 'completed';

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    final rawItems = (data['items'] as List<dynamic>?) ?? [];

    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      items: rawItems
          .map((item) => CartItemModel.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? 'N/A',
      paymentRef: data['paymentRef'] ?? 'N/A',
      status: data['status'] ?? 'Pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentRef': paymentRef,
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}