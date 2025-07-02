import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/utils/supabase_storage_service.dart';
import '../models/feedback_models.dart';

class FeedbackService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final AudioRecorder _recorder = AudioRecorder();
  
  static const String _feedbackCollection = 'feedback';
  static const String _voiceFeedbackBucket = 'voice-feedback';

  /// Submit text feedback
  static Future<UserFeedback> submitFeedback(FeedbackSubmissionRequest request) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to submit feedback');
      }

      final feedbackId = _firestore.collection(_feedbackCollection).doc().id;
      
      // Collect system information if requested
      final metadata = <String, dynamic>{
        ...request.context,
        if (request.includeSystemInfo) ..._getSystemInfo(),
      };

      final feedback = UserFeedback(
        id: feedbackId,
        userId: user.uid,
        type: request.type,
        priority: request.priority,
        status: FeedbackStatus.pending,
        title: request.title,
        description: request.description,
        metadata: metadata,
        tags: request.tags,
        documentId: request.documentId,
        pageReference: request.pageReference,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_feedbackCollection)
          .doc(feedbackId)
          .set(feedback.toJson());

      debugPrint('Feedback submitted successfully: $feedbackId');
      return feedback;
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      rethrow;
    }
  }

  /// Submit voice feedback
  static Future<UserFeedback> submitVoiceFeedback({
    required FeedbackSubmissionRequest request,
    required VoiceFeedbackRecording voiceRecording,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to submit feedback');
      }

      // Upload voice recording to Supabase storage
      final voiceFile = File(voiceRecording.filePath);
      final voiceUrl = await SupabaseStorageService.uploadFile(
        file: voiceFile,
        bucket: _voiceFeedbackBucket,
        filePath: 'feedback/${user.uid}/${voiceRecording.id}.m4a',
      );

      if (voiceUrl == null) {
        throw Exception('Failed to upload voice recording');
      }

      final feedbackId = _firestore.collection(_feedbackCollection).doc().id;
      
      final metadata = <String, dynamic>{
        ...request.context,
        if (request.includeSystemInfo) ..._getSystemInfo(),
        'voiceRecordingInfo': {
          'originalPath': voiceRecording.filePath,
          'duration': voiceRecording.duration.inSeconds,
          'recordedAt': voiceRecording.recordedAt.toIso8601String(),
        },
      };

      final feedback = UserFeedback(
        id: feedbackId,
        userId: user.uid,
        type: request.type,
        priority: request.priority,
        status: FeedbackStatus.pending,
        title: request.title,
        description: request.description,
        voiceNoteUrl: voiceUrl,
        voiceNoteDuration: voiceRecording.duration,
        metadata: metadata,
        tags: [...request.tags, 'voice-feedback'],
        documentId: request.documentId,
        pageReference: request.pageReference,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_feedbackCollection)
          .doc(feedbackId)
          .set(feedback.toJson());

      debugPrint('Voice feedback submitted successfully: $feedbackId');
      return feedback;
    } catch (e) {
      debugPrint('Error submitting voice feedback: $e');
      rethrow;
    }
  }

  /// Start recording voice feedback
  static Future<bool> startVoiceRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final recordingPath = '${tempDir.path}/voice_feedback_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: recordingPath,
        );
        
        debugPrint('Voice recording started: $recordingPath');
        return true;
      } else {
        debugPrint('Microphone permission not granted');
        return false;
      }
    } catch (e) {
      debugPrint('Error starting voice recording: $e');
      return false;
    }
  }

  /// Stop recording voice feedback
  static Future<VoiceFeedbackRecording?> stopVoiceRecording() async {
    try {
      final recordingPath = await _recorder.stop();
      
      if (recordingPath != null) {
        final file = File(recordingPath);
        if (await file.exists()) {
          final duration = await _getAudioDuration(recordingPath);
          
          final recording = VoiceFeedbackRecording(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            filePath: recordingPath,
            duration: duration,
            recordedAt: DateTime.now(),
          );
          
          debugPrint('Voice recording stopped: ${recording.duration.inSeconds}s');
          return recording;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error stopping voice recording: $e');
      return null;
    }
  }

  /// Check if currently recording
  static Future<bool> isRecording() async {
    try {
      return await _recorder.isRecording();
    } catch (e) {
      debugPrint('Error checking recording status: $e');
      return false;
    }
  }

  /// Get user's feedback history
  static Future<List<UserFeedback>> getUserFeedback({
    int limit = 50,
    FeedbackStatus? status,
    FeedbackType? type,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return [];
      }

      Query query = _firestore
          .collection(_feedbackCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      final snapshot = await query.limit(limit).get();
      
      return snapshot.docs
          .map((doc) => UserFeedback.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting user feedback: $e');
      return [];
    }
  }

  /// Get feedback analytics (admin only)
  static Future<FeedbackAnalytics> getFeedbackAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_feedbackCollection);

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate);
      }

      final snapshot = await query.get();
      final feedbackList = snapshot.docs
          .map((doc) => UserFeedback.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();

      return _generateAnalytics(feedbackList);
    } catch (e) {
      debugPrint('Error getting feedback analytics: $e');
      rethrow;
    }
  }

  /// Update feedback status (admin only)
  static Future<void> updateFeedbackStatus({
    required String feedbackId,
    required FeedbackStatus status,
    String? adminResponse,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (adminResponse != null) {
        updateData['adminResponse'] = adminResponse;
      }

      await _firestore
          .collection(_feedbackCollection)
          .doc(feedbackId)
          .update(updateData);

      debugPrint('Feedback status updated: $feedbackId -> ${status.name}');
    } catch (e) {
      debugPrint('Error updating feedback status: $e');
      rethrow;
    }
  }

  /// Delete feedback
  static Future<void> deleteFeedback(String feedbackId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated');
      }

      // Get feedback to check ownership and voice note
      final doc = await _firestore
          .collection(_feedbackCollection)
          .doc(feedbackId)
          .get();

      if (!doc.exists) {
        throw Exception('Feedback not found');
      }

      final feedback = UserFeedback.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });

      // Check ownership
      if (feedback.userId != user.uid) {
        throw Exception('Not authorized to delete this feedback');
      }

      // Delete voice note if exists
      if (feedback.voiceNoteUrl != null) {
        final filePath = SupabaseStorageService.getFilePathFromUrl(feedback.voiceNoteUrl!);
        if (filePath != null) {
          await SupabaseStorageService.deleteFile(
            filePath: filePath,
            bucket: _voiceFeedbackBucket,
          );
        }
      }

      // Delete feedback document
      await _firestore.collection(_feedbackCollection).doc(feedbackId).delete();

      debugPrint('Feedback deleted successfully: $feedbackId');
    } catch (e) {
      debugPrint('Error deleting feedback: $e');
      rethrow;
    }
  }

  // Private helper methods

  static Map<String, dynamic> _getSystemInfo() {
    return {
      'platform': defaultTargetPlatform.name,
      'timestamp': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0', // TODO: Get from package info
      'userAgent': 'VIA Mobile App',
    };
  }

  static Future<Duration> _getAudioDuration(String filePath) async {
    try {
      // This is a simplified implementation
      // In a real app, you'd use an audio library to get actual duration
      final file = File(filePath);
      final fileSize = await file.length();
      
      // Rough estimation: 1 second ≈ 16KB for AAC at 128kbps
      final estimatedSeconds = (fileSize / 16000).round();
      return Duration(seconds: estimatedSeconds.clamp(1, 300)); // Max 5 minutes
    } catch (e) {
      debugPrint('Error getting audio duration: $e');
      return const Duration(seconds: 30); // Default fallback
    }
  }

  static FeedbackAnalytics _generateAnalytics(List<UserFeedback> feedbackList) {
    final feedbackByType = <FeedbackType, int>{};
    final feedbackByPriority = <FeedbackPriority, int>{};
    final feedbackByStatus = <FeedbackStatus, int>{};
    final allTags = <String>[];
    final responseTimes = <double>[];

    for (final feedback in feedbackList) {
      // Count by type
      feedbackByType[feedback.type] = (feedbackByType[feedback.type] ?? 0) + 1;
      
      // Count by priority
      feedbackByPriority[feedback.priority] = (feedbackByPriority[feedback.priority] ?? 0) + 1;
      
      // Count by status
      feedbackByStatus[feedback.status] = (feedbackByStatus[feedback.status] ?? 0) + 1;
      
      // Collect tags
      allTags.addAll(feedback.tags);
      
      // Calculate response time if resolved
      if (feedback.status == FeedbackStatus.resolved && feedback.updatedAt != null) {
        final responseTime = feedback.updatedAt!.difference(feedback.createdAt).inHours.toDouble();
        responseTimes.add(responseTime);
      }
    }

    // Calculate average response time
    final averageResponseTime = responseTimes.isNotEmpty
        ? responseTimes.reduce((a, b) => a + b) / responseTimes.length
        : 0.0;

    // Get common tags
    final tagCounts = <String, int>{};
    for (final tag in allTags) {
      tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
    }
    final commonTags = tagCounts.entries
        .where((e) => e.value > 1)
        .map((e) => e.key)
        .take(10)
        .toList();

    // Generate trends (simplified)
    final feedbackTrends = <String, int>{
      'thisWeek': feedbackList.where((f) => 
        f.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))
      ).length,
      'thisMonth': feedbackList.where((f) => 
        f.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 30)))
      ).length,
    };

    return FeedbackAnalytics(
      totalFeedback: feedbackList.length,
      feedbackByType: feedbackByType,
      feedbackByPriority: feedbackByPriority,
      feedbackByStatus: feedbackByStatus,
      averageResponseTime: averageResponseTime,
      commonTags: commonTags,
      feedbackTrends: feedbackTrends,
      generatedAt: DateTime.now(),
    );
  }
}
