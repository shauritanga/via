import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/smart_prospectus_state.dart';
import '../../../ai_services/data/models/summary_request.dart';
import '../../../ai_services/data/services/ai_summarization_service.dart';
import '../../../translation/data/models/translation_request.dart';
import '../../../translation/data/services/real_time_translation_service.dart';
import '../../../feedback/data/models/feedback_models.dart';
import '../../../feedback/data/services/feedback_service.dart';
import '../../../content_updates/data/models/content_update_models.dart';
import '../../../content_updates/data/services/content_update_service.dart';
import '../../../prospectus/data/models/prospectus_models.dart';
import '../../../prospectus/data/services/prospectus_processing_service.dart';

// Smart Prospectus State Provider
final smartProspectusProvider = StateNotifierProvider<SmartProspectusNotifier, SmartProspectusState>(
  (ref) => SmartProspectusNotifier(),
);

class SmartProspectusNotifier extends StateNotifier<SmartProspectusState> {
  SmartProspectusNotifier() : super(const SmartProspectusState());

  /// Process a document as a smart prospectus
  Future<void> processDocument({
    required String documentId,
    required String filePath,
    required String institutionName,
    String? academicYear,
  }) async {
    state = state.copyWith(
      isProcessing: true,
      processingProgress: 0.0,
      processingMessage: 'Starting document processing...',
      error: null,
    );

    try {
      final prospectus = await ProspectusProcessingService.processProspectusDocument(
        documentId: documentId,
        filePath: filePath,
        institutionName: institutionName,
        academicYear: academicYear,
        onProgress: (progress, message) {
          state = state.copyWith(
            processingProgress: progress,
            processingMessage: message,
          );
        },
      );

      state = state.copyWith(
        isProcessing: false,
        currentProspectus: prospectus,
        processingProgress: 1.0,
        processingMessage: 'Processing completed successfully!',
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
        processingProgress: 0.0,
        processingMessage: null,
      );
    }
  }

  /// Load prospectus by ID
  Future<void> loadProspectus(String prospectusId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // This would typically load from a repository
      // For now, we'll simulate loading
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(
        isLoading: false,
        // currentProspectus: loadedProspectus,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Search courses in current prospectus
  Future<void> searchCourses({
    String? query,
    CourseLevel? level,
    String? department,
  }) async {
    if (state.currentProspectus == null) return;

    state = state.copyWith(isSearching: true);

    try {
      final courses = await ProspectusProcessingService.searchCourses(
        prospectusId: state.currentProspectus!.id,
        query: query,
        level: level,
        department: department,
      );

      state = state.copyWith(
        isSearching: false,
        searchResults: courses,
        lastSearchQuery: query,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        error: e.toString(),
      );
    }
  }

  /// Get course details
  Future<void> getCourseDetails(String courseId, {String language = 'en'}) async {
    if (state.currentProspectus == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final details = await ProspectusProcessingService.getCourseDetails(
        prospectusId: state.currentProspectus!.id,
        courseId: courseId,
        language: language,
      );

      state = state.copyWith(
        isLoading: false,
        selectedCourseDetails: details,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Translate prospectus content
  Future<void> translateProspectus(String targetLanguage) async {
    if (state.currentProspectus == null) return;

    state = state.copyWith(
      isTranslating: true,
      translationProgress: 0.0,
      translationMessage: 'Starting translation...',
    );

    try {
      final translatedProspectus = await ProspectusProcessingService.translateProspectus(
        prospectusId: state.currentProspectus!.id,
        targetLanguage: targetLanguage,
        onProgress: (progress, message) {
          state = state.copyWith(
            translationProgress: progress,
            translationMessage: message,
          );
        },
      );

      state = state.copyWith(
        isTranslating: false,
        currentProspectus: translatedProspectus,
        currentLanguage: targetLanguage,
        translationProgress: 1.0,
        translationMessage: 'Translation completed!',
      );
    } catch (e) {
      state = state.copyWith(
        isTranslating: false,
        error: e.toString(),
        translationProgress: 0.0,
        translationMessage: null,
      );
    }
  }

  /// Summarize content
  Future<void> summarizeContent({
    required String content,
    SummaryLength length = SummaryLength.medium,
    SummaryType type = SummaryType.academic,
  }) async {
    state = state.copyWith(isSummarizing: true);

    try {
      final request = SummaryRequest(
        content: content,
        length: length,
        type: type,
        language: state.currentLanguage,
        context: 'university prospectus',
      );

      final summary = await AISummarizationService.summarizeContent(request);

      state = state.copyWith(
        isSummarizing: false,
        lastSummary: summary,
      );
    } catch (e) {
      state = state.copyWith(
        isSummarizing: false,
        error: e.toString(),
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear search results
  void clearSearchResults() {
    state = state.copyWith(
      searchResults: [],
      lastSearchQuery: null,
    );
  }

  /// Set selected section
  void setSelectedSection(ProspectusSection section) {
    state = state.copyWith(selectedSection: section);
  }
}

// Content Updates Provider
final contentUpdatesProvider = StateNotifierProvider<ContentUpdatesNotifier, ContentUpdatesState>(
  (ref) => ContentUpdatesNotifier(),
);

class ContentUpdatesNotifier extends StateNotifier<ContentUpdatesState> {
  ContentUpdatesNotifier() : super(const ContentUpdatesState());

  /// Initialize content updates
  Future<void> initialize() async {
    await ContentUpdateService.initialize();
    await checkForUpdates();
  }

  /// Check for new updates
  Future<void> checkForUpdates({String? institutionId}) async {
    state = state.copyWith(isLoading: true);

    try {
      final updates = await ContentUpdateService.checkForUpdates(
        institutionId: institutionId,
        since: state.lastSyncAt,
      );

      state = state.copyWith(
        isLoading: false,
        updates: updates,
        lastSyncAt: DateTime.now(),
        hasNewUpdates: updates.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Subscribe to updates
  Future<void> subscribeToUpdates({
    required String institutionId,
    List<UpdateType>? types,
    List<UpdatePriority>? priorities,
  }) async {
    try {
      final subscription = await ContentUpdateService.subscribeToUpdates(
        institutionId: institutionId,
        types: types,
        priorities: priorities,
      );

      state = state.copyWith(subscription: subscription);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get notifications
  Future<void> getNotifications() async {
    try {
      final notifications = await ContentUpdateService.getUserNotifications();
      state = state.copyWith(notifications: notifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await ContentUpdateService.markNotificationAsRead(notificationId);
      await getNotifications(); // Refresh notifications
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Feedback Provider
final feedbackProvider = StateNotifierProvider<FeedbackNotifier, FeedbackState>(
  (ref) => FeedbackNotifier(),
);

class FeedbackNotifier extends StateNotifier<FeedbackState> {
  FeedbackNotifier() : super(const FeedbackState());

  /// Submit text feedback
  Future<void> submitFeedback(FeedbackSubmissionRequest request) async {
    state = state.copyWith(isSubmitting: true);

    try {
      final feedback = await FeedbackService.submitFeedback(request);
      
      state = state.copyWith(
        isSubmitting: false,
        lastSubmittedFeedback: feedback,
        submissionSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
        submissionSuccess: false,
      );
    }
  }

  /// Start voice recording
  Future<void> startVoiceRecording() async {
    final success = await FeedbackService.startVoiceRecording();
    state = state.copyWith(
      isRecording: success,
      recordingError: success ? null : 'Failed to start recording',
    );
  }

  /// Stop voice recording
  Future<void> stopVoiceRecording() async {
    final recording = await FeedbackService.stopVoiceRecording();
    state = state.copyWith(
      isRecording: false,
      currentRecording: recording,
    );
  }

  /// Submit voice feedback
  Future<void> submitVoiceFeedback({
    required FeedbackSubmissionRequest request,
    required VoiceFeedbackRecording recording,
  }) async {
    state = state.copyWith(isSubmitting: true);

    try {
      final feedback = await FeedbackService.submitVoiceFeedback(
        request: request,
        voiceRecording: recording,
      );
      
      state = state.copyWith(
        isSubmitting: false,
        lastSubmittedFeedback: feedback,
        submissionSuccess: true,
        currentRecording: null,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
        submissionSuccess: false,
      );
    }
  }

  /// Get user feedback history
  Future<void> getFeedbackHistory() async {
    state = state.copyWith(isLoading: true);

    try {
      final history = await FeedbackService.getUserFeedback();
      state = state.copyWith(
        isLoading: false,
        feedbackHistory: history,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear submission status
  void clearSubmissionStatus() {
    state = state.copyWith(
      submissionSuccess: false,
      error: null,
    );
  }
}

// Translation Provider
final translationProvider = StateNotifierProvider<TranslationNotifier, TranslationState>(
  (ref) => TranslationNotifier(),
);

class TranslationNotifier extends StateNotifier<TranslationState> {
  TranslationNotifier() : super(const TranslationState());

  /// Initialize translation service
  Future<void> initialize() async {
    await RealTimeTranslationService.initialize();
    state = state.copyWith(
      availableLanguages: RealTimeTranslationService.getAvailableLanguages(),
    );
  }

  /// Translate text
  Future<void> translateText({
    required String text,
    required String fromLanguage,
    required String toLanguage,
    TranslationType type = TranslationType.general,
  }) async {
    state = state.copyWith(isTranslating: true);

    try {
      final request = TranslationRequest(
        text: text,
        fromLanguage: fromLanguage,
        toLanguage: toLanguage,
        type: type,
      );

      final response = await RealTimeTranslationService.translateText(request);

      state = state.copyWith(
        isTranslating: false,
        lastTranslation: response,
        currentLanguage: toLanguage,
      );
    } catch (e) {
      state = state.copyWith(
        isTranslating: false,
        error: e.toString(),
      );
    }
  }

  /// Detect language
  Future<void> detectLanguage(String text) async {
    try {
      final detectedLanguage = await RealTimeTranslationService.detectLanguage(text);
      state = state.copyWith(detectedLanguage: detectedLanguage);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Set current language
  void setCurrentLanguage(String languageCode) {
    state = state.copyWith(currentLanguage: languageCode);
  }

  /// Clear translation cache
  Future<void> clearCache() async {
    await RealTimeTranslationService.clearCache();
  }
}
