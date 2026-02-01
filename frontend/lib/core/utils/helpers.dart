import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class Helpers {
  // Format currency
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  // Format date
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Get time ago
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years sano${years > 1 ? 'o' : ''} ka hor';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months bil${months > 1 ? 'ood' : ''} ka hor';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} maalin${difference.inDays > 1 ? 'o' : ''} ka hor';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saacad${difference.inHours > 1 ? 'o' : ''} ka hor';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} daqiiqo${difference.inMinutes > 1 ? 'o' : ''} ka hor';
    } else {
      return 'Dhawaan';
    }
  }

  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Truncate text
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get status text
  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Sugaya';
      case 'paid':
        return 'Lacag bixiyay';
      case 'shipped':
        return 'La diray';
      case 'delivered':
        return 'Gaarsiisay';
      case 'cancelled':
        return 'La joojiyay';
      default:
        return status;
    }
  }

  // Validate image URL
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http') && (url.contains('.jpg') || 
           url.contains('.jpeg') || url.contains('.png') || 
           url.contains('.webp') || url.contains('.gif'));
  }

  // Get initials from name
  static String getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // Debounce function
  static Function debounce(Function fn, Duration duration) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(duration, () => fn());
    };
  }
}