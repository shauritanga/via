import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

class PlatformService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize platform-specific services
  static Future<void> initialize() async {
    try {
      await _initializeNotifications();
      await _initializeBackgroundTasks();
      await _requestPermissions();

      debugPrint('Platform services initialized successfully');
    } catch (e) {
      debugPrint('Error initializing platform services: $e');
    }
  }

  /// Initialize notifications for both platforms
  static Future<void> _initializeNotifications() async {
    try {
      if (Platform.isAndroid) {
        await _initializeAndroidNotifications();
      } else if (Platform.isIOS) {
        await _initializeIOSNotifications();
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Initialize Android-specific notifications
  static Future<void> _initializeAndroidNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createAndroidNotificationChannels();
  }

  /// Initialize iOS-specific notifications
  static Future<void> _initializeIOSNotifications() async {
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(iOS: iosSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Create Android notification channels
  static Future<void> _createAndroidNotificationChannels() async {
    if (!Platform.isAndroid) return;

    const channels = [
      AndroidNotificationChannel(
        'content_updates',
        'Content Updates',
        description: 'Notifications for prospectus and course updates',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'voice_feedback',
        'Voice Feedback',
        description: 'Notifications related to voice feedback',
        importance: Importance.defaultImportance,
        enableVibration: false,
        playSound: false,
      ),
      AndroidNotificationChannel(
        'system_alerts',
        'System Alerts',
        description: 'Important system notifications',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      ),
    ];

    for (final channel in channels) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  /// Initialize background tasks
  static Future<void> _initializeBackgroundTasks() async {
    try {
      await Workmanager().initialize(
        _backgroundTaskCallback,
        isInDebugMode: kDebugMode,
      );

      // Register platform-specific background tasks
      if (Platform.isAndroid) {
        await _registerAndroidBackgroundTasks();
      } else if (Platform.isIOS) {
        await _registerIOSBackgroundTasks();
      }
    } catch (e) {
      debugPrint('Error initializing background tasks: $e');
    }
  }

  /// Register Android background tasks
  static Future<void> _registerAndroidBackgroundTasks() async {
    // Content update sync - every 30 minutes
    await Workmanager().registerPeriodicTask(
      'content_update_sync',
      'syncContentUpdates',
      frequency: const Duration(minutes: 30),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );

    // Translation cache cleanup - daily
    await Workmanager().registerPeriodicTask(
      'translation_cache_cleanup',
      'cleanupTranslationCache',
      frequency: const Duration(days: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresCharging: false,
        requiresDeviceIdle: true,
      ),
    );
  }

  /// Register iOS background tasks
  static Future<void> _registerIOSBackgroundTasks() async {
    // iOS has more restrictive background processing
    // Register for background app refresh
    await Workmanager().registerOneOffTask(
      'ios_content_sync',
      'syncContentUpdates',
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  /// Request necessary permissions
  static Future<void> _requestPermissions() async {
    try {
      final permissions = <Permission>[];

      // Common permissions
      permissions.addAll([
        Permission.microphone,
        Permission.storage,
        Permission.notification,
      ]);

      // Platform-specific permissions
      if (Platform.isAndroid) {
        permissions.addAll([
          Permission.scheduleExactAlarm,
          Permission.ignoreBatteryOptimizations,
        ]);
      } else if (Platform.isIOS) {
        permissions.addAll([Permission.speech, Permission.photos]);
      }

      // Request permissions
      final statuses = await permissions.request();

      // Log permission results
      for (final entry in statuses.entries) {
        debugPrint('Permission ${entry.key}: ${entry.value}');
      }

      // Handle critical permissions
      await _handleCriticalPermissions(statuses);
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  /// Handle critical permissions that are required for core functionality
  static Future<void> _handleCriticalPermissions(
    Map<Permission, PermissionStatus> statuses,
  ) async {
    final criticalPermissions = [
      Permission.microphone,
      Permission.notification,
    ];

    for (final permission in criticalPermissions) {
      final status = statuses[permission];

      if (status == PermissionStatus.denied ||
          status == PermissionStatus.permanentlyDenied) {
        await _showPermissionDialog(permission);
      }
    }
  }

  /// Show permission dialog for denied permissions
  static Future<void> _showPermissionDialog(Permission permission) async {
    // This would typically show a dialog explaining why the permission is needed
    // For now, just log the issue
    debugPrint('Critical permission denied: $permission');

    if (permission == Permission.microphone) {
      debugPrint(
        'Microphone permission is required for voice commands and feedback',
      );
    } else if (permission == Permission.notification) {
      debugPrint('Notification permission is required for content updates');
    }
  }

  /// Get platform-specific information
  static Map<String, dynamic> getPlatformInfo() {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'isAndroid': Platform.isAndroid,
      'isIOS': Platform.isIOS,
      'locale': Platform.localeName,
      'numberOfProcessors': Platform.numberOfProcessors,
      'pathSeparator': Platform.pathSeparator,
      'isDebugMode': kDebugMode,
      'isProfileMode': kProfileMode,
      'isReleaseMode': kReleaseMode,
    };
  }

  /// Check if a feature is supported on current platform
  static bool isFeatureSupported(String feature) {
    switch (feature) {
      case 'background_sync':
        return Platform.isAndroid; // iOS has limited background processing
      case 'exact_alarms':
        return Platform.isAndroid;
      case 'file_sharing':
        return true; // Both platforms support file sharing
      case 'voice_recording':
        return true; // Both platforms support voice recording
      case 'push_notifications':
        return true; // Both platforms support push notifications
      case 'background_audio':
        return true; // Both platforms support background audio
      default:
        return false;
    }
  }

  /// Get platform-specific storage paths
  static Future<Map<String, String?>> getStoragePaths() async {
    try {
      // This would use path_provider to get platform-specific paths
      return {
        'documents': '/documents', // Placeholder
        'cache': '/cache',
        'temp': '/temp',
        'external': Platform.isAndroid ? '/external' : null,
      };
    } catch (e) {
      debugPrint('Error getting storage paths: $e');
      return {};
    }
  }

  /// Background task callback
  static void _backgroundTaskCallback() {
    Workmanager().executeTask((task, inputData) async {
      try {
        debugPrint('Executing background task: $task');

        switch (task) {
          case 'syncContentUpdates':
            // Sync content updates
            await _syncContentUpdates();
            break;
          case 'cleanupTranslationCache':
            // Cleanup translation cache
            await _cleanupTranslationCache();
            break;
          default:
            debugPrint('Unknown background task: $task');
            return false;
        }

        return true;
      } catch (e) {
        debugPrint('Background task error: $e');
        return false;
      }
    });
  }

  /// Sync content updates in background
  static Future<void> _syncContentUpdates() async {
    try {
      // This would call the ContentUpdateService
      debugPrint('Background sync: Checking for content updates...');
      // await ContentUpdateService.checkForUpdates();
    } catch (e) {
      debugPrint('Background sync error: $e');
    }
  }

  /// Cleanup translation cache
  static Future<void> _cleanupTranslationCache() async {
    try {
      debugPrint('Background cleanup: Cleaning translation cache...');
      // await RealTimeTranslationService.clearCache();
    } catch (e) {
      debugPrint('Cache cleanup error: $e');
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');

    // Handle different notification types
    if (response.payload?.startsWith('content_update:') == true) {
      // Handle content update notification
      final updateId = response.payload!.split(':')[1];
      debugPrint('Opening content update: $updateId');
    } else if (response.payload?.startsWith('feedback:') == true) {
      // Handle feedback notification
      final feedbackId = response.payload!.split(':')[1];
      debugPrint('Opening feedback: $feedbackId');
    }
  }

  /// Send platform-specific notification
  static Future<void> sendNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'content_updates',
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'content_updates',
        'Content Updates',
        channelDescription: 'Notifications for prospectus and course updates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
