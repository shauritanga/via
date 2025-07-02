import 'package:equatable/equatable.dart';

enum FeedbackType {
  contentQuality,
  accessibility,
  translation,
  voiceCommand,
  navigation,
  suggestion,
  bug,
  general,
}

enum FeedbackPriority { low, medium, high, critical }

enum FeedbackStatus { pending, reviewed, resolved, dismissed }

class UserFeedback extends Equatable {
  final String id;
  final String userId;
  final FeedbackType type;
  final FeedbackPriority priority;
  final FeedbackStatus status;
  final String title;
  final String description;
  final String? voiceNoteUrl;
  final Duration? voiceNoteDuration;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final String? documentId;
  final String? pageReference;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminResponse;

  const UserFeedback({
    required this.id,
    required this.userId,
    required this.type,
    required this.priority,
    required this.status,
    required this.title,
    required this.description,
    this.voiceNoteUrl,
    this.voiceNoteDuration,
    required this.metadata,
    required this.tags,
    this.documentId,
    this.pageReference,
    required this.createdAt,
    this.updatedAt,
    this.adminResponse,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'title': title,
      'description': description,
      'voiceNoteUrl': voiceNoteUrl,
      'voiceNoteDuration': voiceNoteDuration?.inSeconds,
      'metadata': metadata,
      'tags': tags,
      'documentId': documentId,
      'pageReference': pageReference,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'adminResponse': adminResponse,
    };
  }

  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    return UserFeedback(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: FeedbackType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FeedbackType.general,
      ),
      priority: FeedbackPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => FeedbackPriority.medium,
      ),
      status: FeedbackStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FeedbackStatus.pending,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      voiceNoteUrl: json['voiceNoteUrl'] as String?,
      voiceNoteDuration: json['voiceNoteDuration'] != null
          ? Duration(seconds: json['voiceNoteDuration'] as int)
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      documentId: json['documentId'] as String?,
      pageReference: json['pageReference'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      adminResponse: json['adminResponse'] as String?,
    );
  }

  UserFeedback copyWith({
    String? id,
    String? userId,
    FeedbackType? type,
    FeedbackPriority? priority,
    FeedbackStatus? status,
    String? title,
    String? description,
    String? voiceNoteUrl,
    Duration? voiceNoteDuration,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? documentId,
    String? pageReference,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminResponse,
  }) {
    return UserFeedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      voiceNoteDuration: voiceNoteDuration ?? this.voiceNoteDuration,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      documentId: documentId ?? this.documentId,
      pageReference: pageReference ?? this.pageReference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminResponse: adminResponse ?? this.adminResponse,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        priority,
        status,
        title,
        description,
        voiceNoteUrl,
        voiceNoteDuration,
        metadata,
        tags,
        documentId,
        pageReference,
        createdAt,
        updatedAt,
        adminResponse,
      ];
}

class FeedbackAnalytics extends Equatable {
  final int totalFeedback;
  final Map<FeedbackType, int> feedbackByType;
  final Map<FeedbackPriority, int> feedbackByPriority;
  final Map<FeedbackStatus, int> feedbackByStatus;
  final double averageResponseTime;
  final List<String> commonTags;
  final Map<String, int> feedbackTrends;
  final DateTime generatedAt;

  const FeedbackAnalytics({
    required this.totalFeedback,
    required this.feedbackByType,
    required this.feedbackByPriority,
    required this.feedbackByStatus,
    required this.averageResponseTime,
    required this.commonTags,
    required this.feedbackTrends,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalFeedback': totalFeedback,
      'feedbackByType': feedbackByType.map((k, v) => MapEntry(k.name, v)),
      'feedbackByPriority': feedbackByPriority.map((k, v) => MapEntry(k.name, v)),
      'feedbackByStatus': feedbackByStatus.map((k, v) => MapEntry(k.name, v)),
      'averageResponseTime': averageResponseTime,
      'commonTags': commonTags,
      'feedbackTrends': feedbackTrends,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory FeedbackAnalytics.fromJson(Map<String, dynamic> json) {
    return FeedbackAnalytics(
      totalFeedback: json['totalFeedback'] as int,
      feedbackByType: (json['feedbackByType'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          FeedbackType.values.firstWhere((e) => e.name == k),
          v as int,
        ),
      ),
      feedbackByPriority: (json['feedbackByPriority'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          FeedbackPriority.values.firstWhere((e) => e.name == k),
          v as int,
        ),
      ),
      feedbackByStatus: (json['feedbackByStatus'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          FeedbackStatus.values.firstWhere((e) => e.name == k),
          v as int,
        ),
      ),
      averageResponseTime: (json['averageResponseTime'] as num).toDouble(),
      commonTags: (json['commonTags'] as List<dynamic>).cast<String>(),
      feedbackTrends: Map<String, int>.from(json['feedbackTrends'] as Map),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        totalFeedback,
        feedbackByType,
        feedbackByPriority,
        feedbackByStatus,
        averageResponseTime,
        commonTags,
        feedbackTrends,
        generatedAt,
      ];
}

class FeedbackSubmissionRequest extends Equatable {
  final FeedbackType type;
  final String title;
  final String description;
  final FeedbackPriority priority;
  final List<String> tags;
  final String? documentId;
  final String? pageReference;
  final Map<String, dynamic> context;
  final bool includeSystemInfo;

  const FeedbackSubmissionRequest({
    required this.type,
    required this.title,
    required this.description,
    this.priority = FeedbackPriority.medium,
    this.tags = const [],
    this.documentId,
    this.pageReference,
    this.context = const {},
    this.includeSystemInfo = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'title': title,
      'description': description,
      'priority': priority.name,
      'tags': tags,
      'documentId': documentId,
      'pageReference': pageReference,
      'context': context,
      'includeSystemInfo': includeSystemInfo,
    };
  }

  @override
  List<Object?> get props => [
        type,
        title,
        description,
        priority,
        tags,
        documentId,
        pageReference,
        context,
        includeSystemInfo,
      ];
}

class VoiceFeedbackRecording extends Equatable {
  final String id;
  final String filePath;
  final Duration duration;
  final DateTime recordedAt;
  final bool isUploaded;
  final String? uploadUrl;

  const VoiceFeedbackRecording({
    required this.id,
    required this.filePath,
    required this.duration,
    required this.recordedAt,
    this.isUploaded = false,
    this.uploadUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'duration': duration.inSeconds,
      'recordedAt': recordedAt.toIso8601String(),
      'isUploaded': isUploaded,
      'uploadUrl': uploadUrl,
    };
  }

  factory VoiceFeedbackRecording.fromJson(Map<String, dynamic> json) {
    return VoiceFeedbackRecording(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      duration: Duration(seconds: json['duration'] as int),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      isUploaded: json['isUploaded'] as bool? ?? false,
      uploadUrl: json['uploadUrl'] as String?,
    );
  }

  VoiceFeedbackRecording copyWith({
    String? id,
    String? filePath,
    Duration? duration,
    DateTime? recordedAt,
    bool? isUploaded,
    String? uploadUrl,
  }) {
    return VoiceFeedbackRecording(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      recordedAt: recordedAt ?? this.recordedAt,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadUrl: uploadUrl ?? this.uploadUrl,
    );
  }

  @override
  List<Object?> get props => [id, filePath, duration, recordedAt, isUploaded, uploadUrl];
}
