import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../classes/transaction.dart';

class DatabaseService {
  // Firestore instance

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('userDetails');
  // Collection reference

  // Add order data
  Future<void> addOrder(Map<String, dynamic> orderData, collectionName) async {
    try {
      final CollectionReference coll =
          FirebaseFirestore.instance.collection(collectionName);

      await coll.add(orderData);
    } catch (e) {
      debugPrint("Error adding order: $e");
    }
  }

  // Update order
  Future<void> updateOrder(String id, Map<String, dynamic> orderData) async {
    try {
      await usersCollection.doc(id).update(orderData);
    } catch (e) {
      debugPrint("Error updating order: $e");
    }
  }

  // Delete order
  Future<void> deleteOrder(String id) async {
    try {
      await usersCollection.doc(id).delete();
    } catch (e) {
      debugPrint("Error deleting order: $e");
    }
  }

// Read data from a collection filtered by email
  Future<List<Map<String, dynamic>>> readDataByEmail(
      String collectionName, String email) async {
    try {
      final CollectionReference coll =
          FirebaseFirestore.instance.collection(collectionName);
      QuerySnapshot querySnapshot = await coll
          .where('email', isEqualTo: email)
          .orderBy('date',
              descending:
                  true) // Replace 'timestamp' with your actual timestamp field
          .get();

      List<Map<String, dynamic>> dataList = [];

      for (var doc in querySnapshot.docs) {
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          dataList.add(data);
        } else {
          debugPrint('Document does not exist');
        }
      }

      return dataList;
    } catch (e) {
      debugPrint("Error reading data: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> readDataByPaymentId(
      String collectionName, String paymentId) async {
    try {
      final CollectionReference coll =
          FirebaseFirestore.instance.collection(collectionName);
      QuerySnapshot querySnapshot = await coll
          .where('paymentId', isEqualTo: paymentId)
          .orderBy('date',
              descending:
                  true) // Replace 'timestamp' with your actual timestamp field
          .get();

      List<Map<String, dynamic>> dataList = [];

      for (var doc in querySnapshot.docs) {
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          dataList.add(data);
        } else {
          debugPrint('Document does not exist');
        }
      }

      return dataList;
    } catch (e) {
      debugPrint("Error reading data: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> readDataByEmailLimit(
      String collectionName, String email) async {
    try {
      final CollectionReference coll =
          FirebaseFirestore.instance.collection(collectionName);
      QuerySnapshot querySnapshot = await coll
          .where('email', isEqualTo: email)
          .orderBy('date',
              descending:
                  true) // Replace 'timestamp' with your actual timestamp field
          .limit(1)
          .get();

      List<Map<String, dynamic>> dataList = [];

      for (var doc in querySnapshot.docs) {
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          dataList.add(data);
        } else {
          debugPrint('Document does not exist');
        }
      }

      return dataList;
    } catch (e) {
      debugPrint("Error reading data: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> readDataByEmailLimitForUserDetails(
      String collectionName, String email) async {
    try {
      final CollectionReference coll =
          FirebaseFirestore.instance.collection(collectionName);
      QuerySnapshot querySnapshot =
          await coll.where('email', isEqualTo: email).limit(1).get();

      List<Map<String, dynamic>> dataList = [];

      for (var doc in querySnapshot.docs) {
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          dataList.add(data);
        } else {
          debugPrint('Document does not exist');
        }
      }

      return dataList;
    } catch (e) {
      debugPrint("Error reading data: $e");
      return [];
    }
  }

  // Add or Update user data based on email
  Future<void> addOrUpdateBookingByEmail(
      String email, Map<String, dynamic> userData, collectionName) async {
    try {
      final CollectionReference coll =
          FirebaseFirestore.instance.collection(collectionName);
      QuerySnapshot querySnapshot = await coll
          .where('email', isEqualTo: email)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Document with email exists, update it
        DocumentReference docRef = querySnapshot.docs.first.reference;
        await docRef.update(userData);
      } else {
        // Document with email does not exist, add new document
        await coll.add(userData);
      }
    } catch (e) {
      debugPrint("Error adding or updating user: $e");
    }
  }

  Future<void> addOrUpdateUserByEmail(
      String email, Map<String, dynamic> userData, collectionName) async {
    try {
      final CollectionReference coll =
          FirebaseFirestore.instance.collection(collectionName);
      QuerySnapshot querySnapshot =
          await coll.where('email', isEqualTo: email).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Document with email exists, update it
        DocumentReference docRef = querySnapshot.docs.first.reference;
        await docRef.update(userData);
      } else {
        // Document with email does not exist, add new document
        await coll.add(userData);
      }
    } catch (e) {
      debugPrint("Error adding or updating user: $e");
    }
  }

  Future<void> updateWalletIfOnline(String email, String collectionName) async {
    try {
      final CollectionReference coll =
          FirebaseFirestore.instance.collection(collectionName);
      QuerySnapshot querySnapshot = await coll
          .where('email', isEqualTo: email)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      debugPrint("onnnnnnnnnnnnnnnnnnnnn**********************");

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot docSnapshot = querySnapshot.docs.first;
        Map<String, dynamic> userData =
            docSnapshot.data() as Map<String, dynamic>;

        // Extract values from the document
        int estPriceInt = userData['estPrice'];
        double estPrice = estPriceInt.toDouble();
        String paymentStatus = userData['paymentStatus'] ?? '';
        String bookingStatus = userData['booking_status'] ?? '';

        // Check payment status and booking status
        if (paymentStatus == "online" && bookingStatus == "cancelled") {
          // Top up wallet with estPrice
          await topupWallet(email, "userDetails", estPrice);
          debugPrint("Wallet updated successfully");
        } else {
          debugPrint(
              "Payment status is not online or booking status is not cancelled. Wallet not updated.");
        }
      } else {
        debugPrint("No document found for the given email.");
      }
    } catch (e) {
      debugPrint("Error updating wallet: $e");
    }
  }

  Future<double> readWallet(String email, String collectionName) async {
    try {
      final CollectionReference coll =
          FirebaseFirestore.instance.collection(collectionName);
      QuerySnapshot querySnapshot =
          await coll.where('email', isEqualTo: email).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference docRef = querySnapshot.docs.first.reference;
        DocumentSnapshot docSnapshot = await docRef.get();
        Map<String, dynamic> userData =
            docSnapshot.data() as Map<String, dynamic>;

        // Check the wallet balance
        double walletBalance = 0.0;

        if (userData['wallet'] != null) {
          if (userData['wallet'] is int) {
            walletBalance = (userData['wallet'] as int).toDouble();
          } else if (userData['wallet'] is double) {
            walletBalance = userData['wallet'] as double;
          }
        }

        return walletBalance;
      } else {
        debugPrint("No document found for the given email.");
        return 0.0; // or any default value you want to return
      }
    } catch (e) {
      debugPrint("Error reading wallet: $e");
      return 0.0; // handle error by returning a default value
    }
  }

  Future<void> topupWallet(
      String email, String collectionName, double topupAmount) async {
    try {
      final CollectionReference coll =
          FirebaseFirestore.instance.collection(collectionName);
      QuerySnapshot querySnapshot =
          await coll.where('email', isEqualTo: email).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference docRef = querySnapshot.docs.first.reference;
        DocumentSnapshot docSnapshot = await docRef.get();
        Map<String, dynamic> userData =
            docSnapshot.data() as Map<String, dynamic>;

        // Check the wallet balance
        double walletBalance = 0.0;

        if (userData['wallet'] != null) {
          if (userData['wallet'] is int) {
            walletBalance = (userData['wallet'] as int).toDouble();
          } else if (userData['wallet'] is double) {
            walletBalance = userData['wallet'] as double;
          }
        }

        // Top up the wallet
        walletBalance += topupAmount;
        await docRef.update({'wallet': walletBalance});
        debugPrint("Wallet topped up successfully.");
      } else {
        debugPrint("No document found for the given email.");
      }
    } catch (e) {
      debugPrint("Error topping up wallet: $e");
    }
  }

  // addOrUpdateUserByEmail("talkwithakshat@gmail.com", )
}

// Record a transaction in Firestore
Future<void> recordTransaction(TransactionModel transaction) async {
  try {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
    debugPrint("Transaction recorded successfully");
  } catch (e) {
    debugPrint("Error recording transaction: $e");
  }
}

// Get transactions for a specific user
Future<List<TransactionModel>> getTransactions(String email) async {
  try {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('email', isEqualTo: email)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) =>
            TransactionModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  } catch (e) {
    debugPrint("Error fetching transactions: $e");
    return [];
  }
}

// This function records a transaction for a booking
Future<void> recordBookingTransaction(
    String email, double amount, String paymentMethod, String transactionId,
    [String paymentStatus = 'success']) async {
  try {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();

    final TransactionModel transaction = TransactionModel(
      id: id,
      email: email,
      amount: amount,
      status: paymentStatus,
      timestamp: DateTime.now(),
      type: 'booking',
      paymentMethod: paymentMethod,
      transactionId: transactionId,
    );

    await recordTransaction(transaction);
    debugPrint("Booking transaction recorded successfully");
  } catch (e) {
    debugPrint("Error recording booking transaction: $e");
  }
}

// This function records a transaction when wallet is used
Future<void> recordWalletTransaction(
    String email, double amount, String bookingId) async {
  try {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();

    final TransactionModel transaction = TransactionModel(
      id: id,
      email: email,
      amount: amount,
      status: 'success',
      timestamp: DateTime.now(),
      type: 'payment',
      paymentMethod: 'wallet',
      transactionId: bookingId,
    );

    await recordTransaction(transaction);
    debugPrint("Wallet payment transaction recorded successfully");
  } catch (e) {
    debugPrint("Error recording wallet transaction: $e");
  }
}

// This function records a refund transaction when a booking is canceled
Future<void> recordRefundTransaction(
    String email, double amount, String bookingId) async {
  try {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();

    final TransactionModel transaction = TransactionModel(
        id: id,
        email: email,
        amount: amount,
        status: 'success',
        timestamp: DateTime.now(),
        type: 'topup', // Using topup type for refunds as it adds to wallet
        paymentMethod: 'refund',
        transactionId: bookingId,
        errorMessage: 'Refund for canceled booking');

    await recordTransaction(transaction);
    debugPrint("Refund transaction recorded successfully");
  } catch (e) {
    debugPrint("Error recording refund transaction: $e");
  }
}


Future<Map<String, dynamic>?> getUserByEmail(
    String email, String collection) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection(collection)
      .where("email", isEqualTo: email)
      .limit(1)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs.first.data();
  }
  return null;
}