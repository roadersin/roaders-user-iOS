import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String email;
  final double amount;
  final String status; // "success", "failed", "pending"
  final DateTime timestamp;
  final String type; // "topup", "withdrawal", "commission", "earning"
  final String? paymentMethod;
  final String? errorMessage;
  final String? transactionId;

  TransactionModel({
    required this.id,
    required this.email,
    required this.amount,
    required this.status,
    required this.timestamp,
    required this.type,
    this.paymentMethod,
    this.errorMessage,
    this.transactionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'amount': amount,
      'status': status,
      'timestamp': timestamp,
      'type': type,
      'paymentMethod': paymentMethod,
      'errorMessage': errorMessage,
      'transactionId': transactionId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      amount: (map['amount'] is int)
          ? (map['amount'] as int).toDouble()
          : map['amount']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'unknown',
      timestamp: (map['timestamp'] is Timestamp)
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      type: map['type'] ?? '',
      paymentMethod: map['paymentMethod'],
      errorMessage: map['errorMessage'],
      transactionId: map['transactionId'] ?? '',
    );
  }
}
