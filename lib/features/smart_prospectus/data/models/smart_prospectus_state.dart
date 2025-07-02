import 'package:equatable/equatable.dart';
import '../../../ai_services/data/models/summary_request.dart';
import '../../../translation/data/models/translation_request.dart';
import '../../../feedback/data/models/feedback_models.dart';
import '../../../content_updates/data/models/content_update_models.dart';
import '../../../prospectus/data/models/prospectus_models.dart';

// Smart Prospectus State
class SmartProspectusState extends Equatable {
  final bool isLoading;
  final bool isProcessing;
  final bool isSearching;
  final bool isTranslating;
  final bool isSummarizing;
  final double processingProgress;
  final double translationProgress;
  final String? processingMessage;
  final String? translationMessage;
  final String? error;
  final ProspectusDocument? currentProspectus;
  final ProspectusSection? selectedSection;
  final List<Course> searchResults;
  final String? lastSearchQuery;
  final Map<String, dynamic>? selectedCourseDetails;
  final String currentLanguage;
  final SummaryResponse? lastSummary;

  const SmartProspectusState({
    this.isLoading = false,
    this.isProcessing = false,
    this.isSearching = false,
    this.isTranslating = false,
    this.isSummarizing = false,
    this.processingProgress = 0.0,
    this.translationProgress = 0.0,
    this.processingMessage,
    this.translationMessage,
    this.error,
    this.currentProspectus,
    this.selectedSection,
    this.searchResults = const [],
    this.lastSearchQuery,
    this.selectedCourseDetails,
    this.currentLanguage = 'en',
    this.lastSummary,
  });

  SmartProspectusState copyWith({
    bool? isLoading,
    bool? isProcessing,
    bool? isSearching,
    bool? isTranslating,
    bool? isSummarizing,
    double? processingProgress,
    double? translationProgress,
    String? processingMessage,
    String? translationMessage,
    String? error,
    ProspectusDocument? currentProspectus,
    ProspectusSection? selectedSection,
    List<Course>? searchResults,
    String? lastSearchQuery,
    Map<String, dynamic>? selectedCourseDetails,
    String? currentLanguage,
    SummaryResponse? lastSummary,
  }) {
    return SmartProspectusState(
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      isSearching: isSearching ?? this.isSearching,
      isTranslating: isTranslating ?? this.isTranslating,
      isSummarizing: isSummarizing ?? this.isSummarizing,
      processingProgress: processingProgress ?? this.processingProgress,
      translationProgress: translationProgress ?? this.translationProgress,
      processingMessage: processingMessage ?? this.processingMessage,
      translationMessage: translationMessage ?? this.translationMessage,
      error: error,
      currentProspectus: currentProspectus ?? this.currentProspectus,
      selectedSection: selectedSection ?? this.selectedSection,
      searchResults: searchResults ?? this.searchResults,
      lastSearchQuery: lastSearchQuery ?? this.lastSearchQuery,
      selectedCourseDetails: selectedCourseDetails ?? this.selectedCourseDetails,
      currentLanguage: currentLanguage ?? this.currentLanguage,
      lastSummary: lastSummary ?? this.lastSummary,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isProcessing,
        isSearching,
        isTranslating,
        isSummarizing,
        processingProgress,
        translationProgress,
        processingMessage,
        translationMessage,
        error,
        currentProspectus,
        selectedSection,
        searchResults,
        lastSearchQuery,
        selectedCourseDetails,
        currentLanguage,
        lastSummary,
      ];
}

// Content Updates State
class ContentUpdatesState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<ContentUpdate> updates;
  final List<UpdateNotification> notifications;
  final UpdateSubscription? subscription;
  final DateTime? lastSyncAt;
  final bool hasNewUpdates;
  final UpdateSyncStatus? syncStatus;

  const ContentUpdatesState({
    this.isLoading = false,
    this.error,
    this.updates = const [],
    this.notifications = const [],
    this.subscription,
    this.lastSyncAt,
    this.hasNewUpdates = false,
    this.syncStatus,
  });

  ContentUpdatesState copyWith({
    bool? isLoading,
    String? error,
    List<ContentUpdate>? updates,
    List<UpdateNotification>? notifications,
    UpdateSubscription? subscription,
    DateTime? lastSyncAt,
    bool? hasNewUpdates,
    UpdateSyncStatus? syncStatus,
  }) {
    return ContentUpdatesState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      updates: updates ?? this.updates,
      notifications: notifications ?? this.notifications,
      subscription: subscription ?? this.subscription,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      hasNewUpdates: hasNewUpdates ?? this.hasNewUpdates,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        updates,
        notifications,
        subscription,
        lastSyncAt,
        hasNewUpdates,
        syncStatus,
      ];
}

// Feedback State
class FeedbackState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final bool isRecording;
  final bool submissionSuccess;
  final String? error;
  final String? recordingError;
  final List<UserFeedback> feedbackHistory;
  final UserFeedback? lastSubmittedFeedback;
  final VoiceFeedbackRecording? currentRecording;

  const FeedbackState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.isRecording = false,
    this.submissionSuccess = false,
    this.error,
    this.recordingError,
    this.feedbackHistory = const [],
    this.lastSubmittedFeedback,
    this.currentRecording,
  });

  FeedbackState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isRecording,
    bool? submissionSuccess,
    String? error,
    String? recordingError,
    List<UserFeedback>? feedbackHistory,
    UserFeedback? lastSubmittedFeedback,
    VoiceFeedbackRecording? currentRecording,
  }) {
    return FeedbackState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isRecording: isRecording ?? this.isRecording,
      submissionSuccess: submissionSuccess ?? this.submissionSuccess,
      error: error,
      recordingError: recordingError,
      feedbackHistory: feedbackHistory ?? this.feedbackHistory,
      lastSubmittedFeedback: lastSubmittedFeedback ?? this.lastSubmittedFeedback,
      currentRecording: currentRecording,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubmitting,
        isRecording,
        submissionSuccess,
        error,
        recordingError,
        feedbackHistory,
        lastSubmittedFeedback,
        currentRecording,
      ];
}

// Translation State
class TranslationState extends Equatable {
  final bool isTranslating;
  final String? error;
  final String currentLanguage;
  final String? detectedLanguage;
  final List<SupportedLanguage> availableLanguages;
  final TranslationResponse? lastTranslation;
  final Map<String, dynamic> cacheStats;

  const TranslationState({
    this.isTranslating = false,
    this.error,
    this.currentLanguage = 'en',
    this.detectedLanguage,
    this.availableLanguages = const [],
    this.lastTranslation,
    this.cacheStats = const {},
  });

  TranslationState copyWith({
    bool? isTranslating,
    String? error,
    String? currentLanguage,
    String? detectedLanguage,
    List<SupportedLanguage>? availableLanguages,
    TranslationResponse? lastTranslation,
    Map<String, dynamic>? cacheStats,
  }) {
    return TranslationState(
      isTranslating: isTranslating ?? this.isTranslating,
      error: error,
      currentLanguage: currentLanguage ?? this.currentLanguage,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
      availableLanguages: availableLanguages ?? this.availableLanguages,
      lastTranslation: lastTranslation ?? this.lastTranslation,
      cacheStats: cacheStats ?? this.cacheStats,
    );
  }

  @override
  List<Object?> get props => [
        isTranslating,
        error,
        currentLanguage,
        detectedLanguage,
        availableLanguages,
        lastTranslation,
        cacheStats,
      ];
}
