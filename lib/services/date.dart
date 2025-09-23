import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String formatTime(dynamic timestamp) {
  try {
    DateTime dateTime;

    if (timestamp is Timestamp) {
      // Handle Firebase Timestamp
      dateTime = timestamp.toDate();
    } else if (timestamp is String) {
      // Handle string timestamp in the original format (fallback)
      final DateFormat timestampFormat = DateFormat('yyyy-MM-dd – kk:mm');
      dateTime = timestampFormat.parse(timestamp);
    } else if (timestamp is int) {
      // Handle Unix timestamp (fallback)
      if (timestamp.toString().length <= 10) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      } else {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } else if (timestamp is DateTime) {
      // Handle DateTime object directly
      dateTime = timestamp;
    } else {
      throw ArgumentError(
          'Unsupported timestamp type: ${timestamp.runtimeType}');
    }

    final DateFormat timeFormat = DateFormat('hh:mm a');
    return timeFormat.format(dateTime);
  } catch (e) {
    debugPrint("Error formatting time: $e");
    return "";
  }
}

String formatDate(dynamic timestamp) {
  try {
    DateTime dateTime;

    if (timestamp is Timestamp) {
      // Handle Firebase Timestamp
      dateTime = timestamp.toDate();
    } else if (timestamp is String) {
      // Handle string timestamp in the original format (fallback)
      final DateFormat timestampFormat = DateFormat('yyyy-MM-dd – kk:mm');
      dateTime = timestampFormat.parse(timestamp);
    } else if (timestamp is int) {
      // Handle Unix timestamp (fallback)
      if (timestamp.toString().length <= 10) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      } else {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } else if (timestamp is DateTime) {
      // Handle DateTime object directly
      dateTime = timestamp;
    } else {
      throw ArgumentError(
          'Unsupported timestamp type: ${timestamp.runtimeType}');
    }

    final DateFormat dateFormat = DateFormat('dd MMMM yyyy');
    return dateFormat.format(dateTime);
  } catch (e) {
    debugPrint("Error formatting date: $e");
    return "";
  }
}

// Specific Firebase Timestamp functions for better type safety
String formatTimeFromFirebase(Timestamp timestamp) {
  try {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat timeFormat = DateFormat('hh:mm a');
    return timeFormat.format(dateTime);
  } catch (e) {
    debugPrint("Error formatting time from Firebase timestamp: $e");
    return "";
  }
}

String formatDateFromFirebase(Timestamp timestamp) {
  try {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat dateFormat = DateFormat('dd MMMM yyyy');
    return dateFormat.format(dateTime);
  } catch (e) {
    debugPrint("Error formatting date from Firebase timestamp: $e");
    return "";
  }
}

// Additional utility functions for Firebase Timestamps
String formatDateTime(Timestamp timestamp) {
  try {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat dateTimeFormat = DateFormat('dd MMMM yyyy, hh:mm a');
    return dateTimeFormat.format(dateTime);
  } catch (e) {
    debugPrint("Error formatting datetime from Firebase timestamp: $e");
    return "";
  }
}

String formatDateTimeShort(Timestamp timestamp) {
  try {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat dateTimeFormat = DateFormat('dd/MM/yyyy hh:mm a');
    return dateTimeFormat.format(dateTime);
  } catch (e) {
    debugPrint("Error formatting short datetime from Firebase timestamp: $e");
    return "";
  }
}

// Helper function to check if timestamp is today
bool isToday(Timestamp timestamp) {
  try {
    final DateTime dateTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  } catch (e) {
    debugPrint("Error checking if timestamp is today: $e");
    return false;
  }
}

// Helper function for relative time (e.g., "2 hours ago")
String formatRelativeTime(Timestamp timestamp) {
  try {
    final DateTime dateTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  } catch (e) {
    debugPrint("Error formatting relative time: $e");
    return "";
  }
}
