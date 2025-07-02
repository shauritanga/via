import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  static const String _logKey = 'app_logs';
  static const int _maxLogs = 1000;
  static const int _maxLogAge = 7; // days

  List<LogEntry> _logs = [];
  bool _isInitialized = false;

  // Initialize logging service
  static Future<void> initialize() async {
    await _instance._loadLogs();
    _instance._isInitialized = true;
    _instance._log(LogLevel.info, 'LoggingService initialized');
  }

  // Log methods
  static void debug(String message, {String? context, Map<String, dynamic>? data}) {
    _instance._log(LogLevel.debug, message, context: context, data: data);
  }

  static void info(String message, {String? context, Map<String, dynamic>? data}) {
    _instance._log(LogLevel.info, message, context: context, data: data);
  }

  static void warning(String message, {String? context, Map<String, dynamic>? data}) {
    _instance._log(LogLevel.warning, message, context: context, data: data);
  }

  static void error(String message, {String? context, Map<String, dynamic>? data}) {
    _instance._log(LogLevel.error, message, context: context, data: data);
  }

  static void critical(String message, {String? context, Map<String, dynamic>? data}) {
    _instance._log(LogLevel.critical, message, context: context, data: data);
  }

  // Internal logging method
  void _log(LogLevel level, String message, {String? context, Map<String, dynamic>? data}) {
    final entry = LogEntry(
      level: level,
      message: message,
      context: context,
      data: data,
      timestamp: DateTime.now(),
    );

    _logs.add(entry);

    // Keep logs within size limit
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    // Remove old logs
    _cleanOldLogs();

    // Console output in debug mode
    if (kDebugMode) {
      _printToConsole(entry);
    }

    // Save logs periodically
    _saveLogs();
  }

  // Print to console with proper formatting
  void _printToConsole(LogEntry entry) {
    final levelEmoji = _getLevelEmoji(entry.level);
    final levelName = entry.level.name.toUpperCase();
    final timestamp = _formatTimestamp(entry.timestamp);
    final context = entry.context != null ? ' [${entry.context}]' : '';
    
    debugPrint('$levelEmoji $timestamp $levelName$context: ${entry.message}');
    
    if (entry.data != null && entry.data!.isNotEmpty) {
      debugPrint('   📊 Data: ${entry.data}');
    }
  }

  String _getLevelEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🚨';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}';
  }

  // Clean old logs
  void _cleanOldLogs() {
    final cutoffDate = DateTime.now().subtract(Duration(days: _maxLogAge));
    _logs.removeWhere((log) => log.timestamp.isBefore(cutoffDate));
  }

  // Load logs from storage
  Future<void> _loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logData = prefs.getStringList(_logKey) ?? [];
      
      _logs = logData
          .map((json) => LogEntry.fromJson(json))
          .where((entry) => entry != null)
          .cast<LogEntry>()
          .toList();
      
      debugPrint('📚 Loaded ${_logs.length} log entries');
    } catch (e) {
      debugPrint('❌ Failed to load logs: $e');
    }
  }

  // Save logs to storage
  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logData = _logs.map((entry) => entry.toJson()).toList();
      await prefs.setStringList(_logKey, logData);
    } catch (e) {
      debugPrint('❌ Failed to save logs: $e');
    }
  }

  // Get logs with filtering
  static List<LogEntry> getLogs({
    LogLevel? minLevel,
    String? context,
    DateTime? since,
    int? limit,
  }) {
    var filteredLogs = _instance._logs;

    if (minLevel != null) {
      filteredLogs = filteredLogs.where((log) => 
          log.level.index >= minLevel.index).toList();
    }

    if (context != null) {
      filteredLogs = filteredLogs.where((log) => 
          log.context == context).toList();
    }

    if (since != null) {
      filteredLogs = filteredLogs.where((log) => 
          log.timestamp.isAfter(since)).toList();
    }

    if (limit != null) {
      filteredLogs = filteredLogs.take(limit).toList();
    }

    return filteredLogs;
  }

  // Get log statistics
  static Map<String, dynamic> getLogStatistics() {
    final logs = _instance._logs;
    final now = DateTime.now();
    
    final last24Hours = logs.where((log) => 
        now.difference(log.timestamp).inHours < 24).length;
    final last7Days = logs.where((log) => 
        now.difference(log.timestamp).inDays < 7).length;

    final levelCounts = <LogLevel, int>{};
    for (final level in LogLevel.values) {
      levelCounts[level] = logs.where((log) => log.level == level).length;
    }

    return {
      'totalLogs': logs.length,
      'logsLast24Hours': last24Hours,
      'logsLast7Days': last7Days,
      'levelCounts': levelCounts.map((key, value) => 
          MapEntry(key.name, value)),
      'mostActiveContext': _getMostActiveContext(logs),
    };
  }

  static String _getMostActiveContext(List<LogEntry> logs) {
    final contextCounts = <String, int>{};
    
    for (final log in logs) {
      if (log.context != null) {
        contextCounts[log.context!] = (contextCounts[log.context!] ?? 0) + 1;
      }
    }

    if (contextCounts.isEmpty) return 'No context';

    final mostActive = contextCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    return '${mostActive.key} (${mostActive.value} logs)';
  }

  // Clear all logs
  static Future<void> clearLogs() async {
    _instance._logs.clear();
    await _instance._saveLogs();
    debugPrint('🗑️ All logs cleared');
  }

  // Export logs for debugging
  static String exportLogs({LogLevel? minLevel, int? limit}) {
    final logs = getLogs(minLevel: minLevel, limit: limit);
    final buffer = StringBuffer();
    
    buffer.writeln('=== VIA App Logs ===');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total logs: ${logs.length}');
    buffer.writeln();
    
    for (final log in logs) {
      buffer.writeln('[${log.timestamp}] ${log.level.name.toUpperCase()}: ${log.message}');
      if (log.context != null) {
        buffer.writeln('  Context: ${log.context}');
      }
      if (log.data != null && log.data!.isNotEmpty) {
        buffer.writeln('  Data: ${log.data}');
      }
      buffer.writeln();
    }
    
    return buffer.toString();
  }
}

class LogEntry {
  final LogLevel level;
  final String message;
  final String? context;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.message,
    this.context,
    this.data,
    required this.timestamp,
  });

  // Convert to JSON for storage
  String toJson() {
    return {
      'level': level.index,
      'message': message,
      'context': context,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
    }.toString();
  }

  // Create from JSON
  static LogEntry? fromJson(String json) {
    try {
      // Simple JSON parsing for storage
      final data = json.replaceAll('{', '').replaceAll('}', '');
      final parts = data.split(', ');
      
      int levelIndex = 0;
      String message = '';
      String? context;
      Map<String, dynamic>? dataMap;
      int timestamp = 0;

      for (final part in parts) {
        if (part.startsWith('level: ')) {
          levelIndex = int.parse(part.substring(7));
        } else if (part.startsWith('message: ')) {
          message = part.substring(9);
        } else if (part.startsWith('context: ')) {
          context = part.substring(9);
        } else if (part.startsWith('timestamp: ')) {
          timestamp = int.parse(part.substring(11));
        }
      }

      return LogEntry(
        level: LogLevel.values[levelIndex],
        message: message,
        context: context,
        data: dataMap,
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      );
    } catch (e) {
      debugPrint('❌ Failed to parse log entry: $e');
      return null;
    }
  }

  @override
  String toString() {
    return 'LogEntry(level: $level, message: $message, context: $context, timestamp: $timestamp)';
  }
} 