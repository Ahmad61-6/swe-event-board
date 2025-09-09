import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void logFlutterError(FlutterErrorDetails details) {
    if (kDebugMode) {
      print('Flutter Error: ${details.exception}');
      print('Stack: ${details.stack}');
    }

    // Log to Firestore
    _logToFirestore('error', details.exception.toString(), {
      'stackTrace': details.stack.toString(),
      'library': details.library ?? '',
      'context': details.context?.toString() ?? '',
    });
  }

  static void logError(Object error, StackTrace stack) {
    if (kDebugMode) {
      print('Error: $error');
      print('Stack: $stack');
    }

    // Log to Firestore
    _logToFirestore('error', error.toString(), {
      'stackTrace': stack.toString(),
    });
  }

  static Future<void> _logToFirestore(
    String level,
    String message,
    Map<String, dynamic> context,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('app_logs').add({
        'level': level,
        'message': message,
        'context': context,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log error: $e');
      }
    }
  }
}
