import 'package:flutter/foundation.dart';
import 'package:via/core/errors/failures.dart';

class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  // Error tracking
  final List<ErrorLog> _errorLogs = [];
  static const int maxErrorLogs = 100;

  // Error handling methods
  static void handleError(dynamic error, StackTrace? stackTrace, {String? context}) {
    final errorLog = ErrorLog(
      error: error,
      stackTrace: stackTrace,
      context: context,
      timestamp: DateTime.now(),
    );

    _instance._logError(errorLog);
    _instance._reportError(errorLog);
  }

  static void handleFailure(Failure failure, {String? context}) {
    final errorLog = ErrorLog(
      error: failure,
      stackTrace: StackTrace.current,
      context: context,
      timestamp: DateTime.now(),
    );

    _instance._logError(errorLog);
    _instance._reportError(errorLog);
  }

  // Log error internally
  void _logError(ErrorLog errorLog) {
    _errorLogs.add(errorLog);
    
    // Keep only the last maxErrorLogs
    if (_errorLogs.length > maxErrorLogs) {
      _errorLogs.removeAt(0);
    }

    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('❌ Error: ${errorLog.error}');
      debugPrint('📍 Context: ${errorLog.context ?? 'No context'}');
      debugPrint('⏰ Timestamp: ${errorLog.timestamp}');
      if (errorLog.stackTrace != null) {
        debugPrint('📚 Stack Trace: ${errorLog.stackTrace}');
      }
    }
  }

  // Report error to external service (Firebase Crashlytics, etc.)
  void _reportError(ErrorLog errorLog) {
    // In production, this would send to Firebase Crashlytics or similar
    if (!kDebugMode) {
      // TODO: Implement Firebase Crashlytics reporting
      debugPrint('📊 Error reported to analytics service');
    }
  }

  // Get user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    if (error is Failure) {
      return _getFailureMessage(error);
    }

    if (error is Exception) {
      return _getExceptionMessage(error);
    }

    return 'An unexpected error occurred. Please try again.';
  }

  static String _getFailureMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Unable to connect to the server. Please check your internet connection and try again.';
      case NetworkFailure:
        return 'Network error. Please check your internet connection.';
      case CacheFailure:
        return 'Unable to access local data. Please restart the app.';
      case DocumentNotFoundFailure:
        return 'Document not found. It may have been moved or deleted.';
      case DocumentParsingFailure:
        return 'Unable to process this document. Please try a different file.';
      case PermissionFailure:
        return 'Permission denied. Please grant the required permissions in settings.';
      case AuthenticationFailure:
        return 'Authentication failed. Please sign in again.';
      case SpeechRecognitionFailure:
        return 'Voice recognition failed. Please try speaking again.';
      case TextToSpeechFailure:
        return 'Unable to read text aloud. Please check your device settings.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  static String _getExceptionMessage(Exception exception) {
    final message = exception.toString().toLowerCase();
    
    if (message.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (message.contains('connection')) {
      return 'Connection error. Please check your internet connection.';
    }
    if (message.contains('permission')) {
      return 'Permission denied. Please check app permissions.';
    }
    if (message.contains('file')) {
      return 'File access error. Please try again.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  // Get error logs for debugging
  static List<ErrorLog> getErrorLogs() {
    return List.unmodifiable(_instance._errorLogs);
  }

  // Clear error logs
  static void clearErrorLogs() {
    _instance._errorLogs.clear();
  }

  // Get error statistics
  static Map<String, dynamic> getErrorStatistics() {
    final logs = _instance._errorLogs;
    final now = DateTime.now();
    final last24Hours = logs.where((log) => 
        now.difference(log.timestamp).inHours < 24).length;
    final last7Days = logs.where((log) => 
        now.difference(log.timestamp).inDays < 7).length;

    return {
      'totalErrors': logs.length,
      'errorsLast24Hours': last24Hours,
      'errorsLast7Days': last7Days,
      'mostCommonError': _getMostCommonError(logs),
    };
  }

  static String _getMostCommonError(List<ErrorLog> logs) {
    final errorTypes = <String, int>{};
    
    for (final log in logs) {
      final errorType = log.error.runtimeType.toString();
      errorTypes[errorType] = (errorTypes[errorType] ?? 0) + 1;
    }

    if (errorTypes.isEmpty) return 'No errors';

    final mostCommon = errorTypes.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    return '${mostCommon.key} (${mostCommon.value} times)';
  }

  // Check if error is recoverable
  static bool isRecoverable(dynamic error) {
    if (error is Failure) {
      return error is! AuthenticationFailure && 
             error is! PermissionFailure;
    }
    
    return true;
  }

  // Suggest recovery action
  static String getRecoverySuggestion(dynamic error) {
    if (error is NetworkFailure) {
      return 'Check your internet connection and try again.';
    }
    if (error is ServerFailure) {
      return 'The server is temporarily unavailable. Please try again later.';
    }
    if (error is PermissionFailure) {
      return 'Go to Settings > Apps > VIA > Permissions and grant the required permissions.';
    }
    if (error is AuthenticationFailure) {
      return 'Please sign in again to continue.';
    }
    
    return 'Try restarting the app.';
  }
}

class ErrorLog {
  final dynamic error;
  final StackTrace? stackTrace;
  final String? context;
  final DateTime timestamp;

  ErrorLog({
    required this.error,
    this.stackTrace,
    this.context,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'ErrorLog(error: $error, context: $context, timestamp: $timestamp)';
  }
}

// Global error handler
class GlobalErrorHandler {
  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      ErrorHandlingService.handleError(
        details.exception,
        details.stack,
        context: 'Flutter Error: ${details.library}',
      );
    };
  }
} 