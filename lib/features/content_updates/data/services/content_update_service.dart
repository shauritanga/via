import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/content_update_models.dart';

class ContentUpdateService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _updatesCollection = 'content_updates';
  static const String _subscriptionsCollection = 'update_subscriptions';
  static const String _notificationsCollection = 'update_notifications';

  static StreamSubscription<QuerySnapshot>? _updateSubscription;
  static Timer? _syncTimer;

  /// Initialize the content update service
  static Future<void> initialize() async {
    await _initializeNotifications();
    await _initializeBackgroundSync();
    await _startRealTimeUpdates();
  }

  /// Check for new updates
  static Future<List<ContentUpdate>> checkForUpdates({
    String? institutionId,
    DateTime? since,
    List<UpdateType>? types,
  }) async {
    try {
      Query query = _firestore
          .collection(_updatesCollection)
          .where('status', isEqualTo: UpdateStatus.published.name)
          .orderBy('effectiveDate', descending: true);

      if (institutionId != null) {
        query = query.where('institutionId', isEqualTo: institutionId);
      }

      if (since != null) {
        query = query.where('effectiveDate', isGreaterThan: since);
      }

      if (types != null && types.isNotEmpty) {
        query = query.where('type', whereIn: types.map((t) => t.name).toList());
      }

      final snapshot = await query.limit(50).get();

      final updates = snapshot.docs
          .map(
            (doc) => ContentUpdate.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      debugPrint('Found ${updates.length} content updates');
      return updates;
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return [];
    }
  }

  /// Get updates for specific documents
  static Future<List<ContentUpdate>> getUpdatesForDocument(
    String documentId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_updatesCollection)
          .where('affectedDocuments', arrayContains: documentId)
          .where('status', isEqualTo: UpdateStatus.published.name)
          .orderBy('effectiveDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ContentUpdate.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      debugPrint('Error getting updates for document: $e');
      return [];
    }
  }

  /// Subscribe to updates
  static Future<UpdateSubscription> subscribeToUpdates({
    required String institutionId,
    List<UpdateType>? types,
    List<UpdatePriority>? priorities,
    bool emailNotifications = true,
    bool pushNotifications = true,
    bool voiceAnnouncements = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated');
      }

      final subscriptionId = '${user.uid}_$institutionId';

      final subscription = UpdateSubscription(
        id: subscriptionId,
        userId: user.uid,
        institutionId: institutionId,
        subscribedTypes: types ?? UpdateType.values,
        subscribedPriorities: priorities ?? UpdatePriority.values,
        emailNotifications: emailNotifications,
        pushNotifications: pushNotifications,
        voiceAnnouncements: voiceAnnouncements,
        preferences: {
          'language': 'en', // TODO: Get from user preferences
          'timezone': DateTime.now().timeZoneName,
        },
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_subscriptionsCollection)
          .doc(subscriptionId)
          .set(subscription.toJson());

      debugPrint('Subscribed to updates for institution: $institutionId');
      return subscription;
    } catch (e) {
      debugPrint('Error subscribing to updates: $e');
      rethrow;
    }
  }

  /// Get user's subscription
  static Future<UpdateSubscription?> getUserSubscription(
    String institutionId,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final subscriptionId = '${user.uid}_$institutionId';
      final doc = await _firestore
          .collection(_subscriptionsCollection)
          .doc(subscriptionId)
          .get();

      if (doc.exists) {
        return UpdateSubscription.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }

      return null;
    } catch (e) {
      debugPrint('Error getting user subscription: $e');
      return null;
    }
  }

  /// Update subscription preferences
  static Future<void> updateSubscriptionPreferences({
    required String institutionId,
    List<UpdateType>? types,
    List<UpdatePriority>? priorities,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? voiceAnnouncements,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated');
      }

      final subscriptionId = '${user.uid}_$institutionId';
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (types != null) {
        updateData['subscribedTypes'] = types.map((t) => t.name).toList();
      }

      if (priorities != null) {
        updateData['subscribedPriorities'] = priorities
            .map((p) => p.name)
            .toList();
      }

      if (emailNotifications != null) {
        updateData['emailNotifications'] = emailNotifications;
      }

      if (pushNotifications != null) {
        updateData['pushNotifications'] = pushNotifications;
      }

      if (voiceAnnouncements != null) {
        updateData['voiceAnnouncements'] = voiceAnnouncements;
      }

      await _firestore
          .collection(_subscriptionsCollection)
          .doc(subscriptionId)
          .update(updateData);

      debugPrint('Updated subscription preferences for: $institutionId');
    } catch (e) {
      debugPrint('Error updating subscription preferences: $e');
      rethrow;
    }
  }

  /// Get user's notifications
  static Future<List<UpdateNotification>> getUserNotifications({
    int limit = 50,
    bool? isRead,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      Query query = _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('sentAt', descending: true);

      if (isRead != null) {
        query = query.where('isRead', isEqualTo: isRead);
      }

      final snapshot = await query.limit(limit).get();

      return snapshot.docs
          .map(
            (doc) => UpdateNotification.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting user notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true, 'readAt': DateTime.now().toIso8601String()});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Get sync status
  static Future<UpdateSyncStatus> getSyncStatus() async {
    try {
      // This would typically be stored in local storage or user preferences
      return UpdateSyncStatus(
        lastSyncAt: DateTime.now().subtract(const Duration(minutes: 5)),
        pendingUpdates: 0,
        failedSyncs: 0,
        isOnline: true,
      );
    } catch (e) {
      debugPrint('Error getting sync status: $e');
      return UpdateSyncStatus(
        lastSyncAt: DateTime.now().subtract(const Duration(hours: 1)),
        pendingUpdates: 0,
        failedSyncs: 1,
        isOnline: false,
        lastError: e.toString(),
      );
    }
  }

  /// Start real-time updates listener
  static Future<void> _startRealTimeUpdates() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Listen for new updates
      _updateSubscription = _firestore
          .collection(_updatesCollection)
          .where('status', isEqualTo: UpdateStatus.published.name)
          .where(
            'effectiveDate',
            isGreaterThan: DateTime.now().subtract(const Duration(days: 1)),
          )
          .snapshots()
          .listen((snapshot) {
            for (final change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final update = ContentUpdate.fromJson({
                  'id': change.doc.id,
                  ...change.doc.data() as Map<String, dynamic>,
                });
                _handleNewUpdate(update);
              }
            }
          });

      debugPrint('Started real-time updates listener');
    } catch (e) {
      debugPrint('Error starting real-time updates: $e');
    }
  }

  /// Handle new update
  static Future<void> _handleNewUpdate(ContentUpdate update) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Check if user is subscribed to this type of update
      final subscription = await getUserSubscription(update.institutionId);
      if (subscription == null) return;

      final isSubscribedToType = subscription.subscribedTypes.contains(
        update.type,
      );
      final isSubscribedToPriority = subscription.subscribedPriorities.contains(
        update.priority,
      );

      if (!isSubscribedToType || !isSubscribedToPriority) return;

      // Create notification
      final notificationId = _firestore
          .collection(_notificationsCollection)
          .doc()
          .id;
      final notification = UpdateNotification(
        id: notificationId,
        userId: user.uid,
        updateId: update.id,
        isImportant: update.priority == UpdatePriority.critical,
        sentAt: DateTime.now(),
        preferences: subscription.preferences,
      );

      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .set(notification.toJson());

      // Send push notification if enabled
      if (subscription.pushNotifications) {
        await _sendPushNotification(update, notification);
      }

      // Announce via voice if enabled
      if (subscription.voiceAnnouncements) {
        await _announceUpdate(update);
      }

      debugPrint('Handled new update: ${update.title}');
    } catch (e) {
      debugPrint('Error handling new update: $e');
    }
  }

  /// Initialize notifications
  static Future<void> _initializeNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(initSettings);
      debugPrint('Notifications initialized');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Send push notification
  static Future<void> _sendPushNotification(
    ContentUpdate update,
    UpdateNotification notification,
  ) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'content_updates',
        'Content Updates',
        channelDescription: 'Notifications for prospectus and course updates',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        notification.id.hashCode,
        update.title,
        update.description,
        details,
        payload: update.id,
      );

      debugPrint('Push notification sent: ${update.title}');
    } catch (e) {
      debugPrint('Error sending push notification: $e');
    }
  }

  /// Announce update via voice
  static Future<void> _announceUpdate(ContentUpdate update) async {
    try {
      // This would integrate with your TTS service
      // For now, just log the announcement
      final announcement = 'New ${update.type.name} update: ${update.title}';
      debugPrint('Voice announcement: $announcement');

      // TODO: Integrate with TTS service
      // await TTSService.speak(announcement);
    } catch (e) {
      debugPrint('Error announcing update: $e');
    }
  }

  /// Initialize background sync
  static Future<void> _initializeBackgroundSync() async {
    try {
      await Workmanager().initialize(
        _backgroundSyncCallback,
        isInDebugMode: kDebugMode,
      );

      // Schedule periodic sync every 30 minutes
      await Workmanager().registerPeriodicTask(
        'content_update_sync',
        'syncContentUpdates',
        frequency: const Duration(minutes: 30),
        constraints: Constraints(networkType: NetworkType.connected),
      );

      debugPrint('Background sync initialized');
    } catch (e) {
      debugPrint('Error initializing background sync: $e');
    }
  }

  /// Background sync callback
  static void _backgroundSyncCallback() {
    Workmanager().executeTask((task, inputData) async {
      try {
        if (task == 'syncContentUpdates') {
          await checkForUpdates();
          debugPrint('Background sync completed');
          return Future.value(true);
        }
        return Future.value(false);
      } catch (e) {
        debugPrint('Background sync error: $e');
        return Future.value(false);
      }
    });
  }

  /// Dispose resources
  static void dispose() {
    _updateSubscription?.cancel();
    _syncTimer?.cancel();
  }
}
