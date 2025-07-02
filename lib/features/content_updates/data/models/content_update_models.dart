import 'package:equatable/equatable.dart';

enum UpdateType {
  prospectusRevision,
  courseChange,
  requirementUpdate,
  newProgram,
  programDiscontinued,
  feeUpdate,
  deadlineChange,
  contactUpdate,
  policyChange,
  general,
}

enum UpdatePriority { low, medium, high, critical }

enum UpdateStatus { pending, published, archived }

class ContentUpdate extends Equatable {
  final String id;
  final String institutionId;
  final UpdateType type;
  final UpdatePriority priority;
  final UpdateStatus status;
  final String title;
  final String description;
  final String? detailedContent;
  final Map<String, dynamic> metadata;
  final List<String> affectedDocuments;
  final List<String> affectedSections;
  final DateTime effectiveDate;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String createdBy;
  final List<String> tags;
  final Map<String, String> translations;

  const ContentUpdate({
    required this.id,
    required this.institutionId,
    required this.type,
    required this.priority,
    required this.status,
    required this.title,
    required this.description,
    this.detailedContent,
    required this.metadata,
    required this.affectedDocuments,
    required this.affectedSections,
    required this.effectiveDate,
    this.expiryDate,
    required this.createdAt,
    this.publishedAt,
    required this.createdBy,
    required this.tags,
    required this.translations,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institutionId': institutionId,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'title': title,
      'description': description,
      'detailedContent': detailedContent,
      'metadata': metadata,
      'affectedDocuments': affectedDocuments,
      'affectedSections': affectedSections,
      'effectiveDate': effectiveDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'createdBy': createdBy,
      'tags': tags,
      'translations': translations,
    };
  }

  factory ContentUpdate.fromJson(Map<String, dynamic> json) {
    return ContentUpdate(
      id: json['id'] as String,
      institutionId: json['institutionId'] as String,
      type: UpdateType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => UpdateType.general,
      ),
      priority: UpdatePriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => UpdatePriority.medium,
      ),
      status: UpdateStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UpdateStatus.pending,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      detailedContent: json['detailedContent'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      affectedDocuments: (json['affectedDocuments'] as List<dynamic>)
          .cast<String>(),
      affectedSections: (json['affectedSections'] as List<dynamic>)
          .cast<String>(),
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      createdBy: json['createdBy'] as String,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      translations: Map<String, String>.from(json['translations'] as Map),
    );
  }

  ContentUpdate copyWith({
    String? id,
    String? institutionId,
    UpdateType? type,
    UpdatePriority? priority,
    UpdateStatus? status,
    String? title,
    String? description,
    String? detailedContent,
    Map<String, dynamic>? metadata,
    List<String>? affectedDocuments,
    List<String>? affectedSections,
    DateTime? effectiveDate,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? publishedAt,
    String? createdBy,
    List<String>? tags,
    Map<String, String>? translations,
  }) {
    return ContentUpdate(
      id: id ?? this.id,
      institutionId: institutionId ?? this.institutionId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      detailedContent: detailedContent ?? this.detailedContent,
      metadata: metadata ?? this.metadata,
      affectedDocuments: affectedDocuments ?? this.affectedDocuments,
      affectedSections: affectedSections ?? this.affectedSections,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      createdBy: createdBy ?? this.createdBy,
      tags: tags ?? this.tags,
      translations: translations ?? this.translations,
    );
  }

  @override
  List<Object?> get props => [
    id,
    institutionId,
    type,
    priority,
    status,
    title,
    description,
    detailedContent,
    metadata,
    affectedDocuments,
    affectedSections,
    effectiveDate,
    expiryDate,
    createdAt,
    publishedAt,
    createdBy,
    tags,
    translations,
  ];
}

class UpdateNotification extends Equatable {
  final String id;
  final String userId;
  final String updateId;
  final bool isRead;
  final bool isImportant;
  final DateTime sentAt;
  final DateTime? readAt;
  final Map<String, dynamic> preferences;

  const UpdateNotification({
    required this.id,
    required this.userId,
    required this.updateId,
    this.isRead = false,
    this.isImportant = false,
    required this.sentAt,
    this.readAt,
    required this.preferences,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'updateId': updateId,
      'isRead': isRead,
      'isImportant': isImportant,
      'sentAt': sentAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'preferences': preferences,
    };
  }

  factory UpdateNotification.fromJson(Map<String, dynamic> json) {
    return UpdateNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      updateId: json['updateId'] as String,
      isRead: json['isRead'] as bool? ?? false,
      isImportant: json['isImportant'] as bool? ?? false,
      sentAt: DateTime.parse(json['sentAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      preferences: Map<String, dynamic>.from(json['preferences'] as Map),
    );
  }

  UpdateNotification copyWith({
    String? id,
    String? userId,
    String? updateId,
    bool? isRead,
    bool? isImportant,
    DateTime? sentAt,
    DateTime? readAt,
    Map<String, dynamic>? preferences,
  }) {
    return UpdateNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updateId: updateId ?? this.updateId,
      isRead: isRead ?? this.isRead,
      isImportant: isImportant ?? this.isImportant,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    updateId,
    isRead,
    isImportant,
    sentAt,
    readAt,
    preferences,
  ];
}

class UpdateSubscription extends Equatable {
  final String id;
  final String userId;
  final String institutionId;
  final List<UpdateType> subscribedTypes;
  final List<UpdatePriority> subscribedPriorities;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool voiceAnnouncements;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UpdateSubscription({
    required this.id,
    required this.userId,
    required this.institutionId,
    required this.subscribedTypes,
    required this.subscribedPriorities,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.voiceAnnouncements = false,
    required this.preferences,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'institutionId': institutionId,
      'subscribedTypes': subscribedTypes.map((e) => e.name).toList(),
      'subscribedPriorities': subscribedPriorities.map((e) => e.name).toList(),
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'voiceAnnouncements': voiceAnnouncements,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UpdateSubscription.fromJson(Map<String, dynamic> json) {
    return UpdateSubscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      institutionId: json['institutionId'] as String,
      subscribedTypes: (json['subscribedTypes'] as List<dynamic>)
          .map((e) => UpdateType.values.firstWhere((type) => type.name == e))
          .toList(),
      subscribedPriorities: (json['subscribedPriorities'] as List<dynamic>)
          .map(
            (e) => UpdatePriority.values.firstWhere(
              (priority) => priority.name == e,
            ),
          )
          .toList(),
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      voiceAnnouncements: json['voiceAnnouncements'] as bool? ?? false,
      preferences: Map<String, dynamic>.from(json['preferences'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    institutionId,
    subscribedTypes,
    subscribedPriorities,
    emailNotifications,
    pushNotifications,
    voiceAnnouncements,
    preferences,
    createdAt,
    updatedAt,
  ];
}

class UpdateSyncStatus extends Equatable {
  final DateTime lastSyncAt;
  final int pendingUpdates;
  final int failedSyncs;
  final bool isOnline;
  final String? lastError;

  const UpdateSyncStatus({
    required this.lastSyncAt,
    this.pendingUpdates = 0,
    this.failedSyncs = 0,
    this.isOnline = true,
    this.lastError,
  });

  Map<String, dynamic> toJson() {
    return {
      'lastSyncAt': lastSyncAt.toIso8601String(),
      'pendingUpdates': pendingUpdates,
      'failedSyncs': failedSyncs,
      'isOnline': isOnline,
      'lastError': lastError,
    };
  }

  factory UpdateSyncStatus.fromJson(Map<String, dynamic> json) {
    return UpdateSyncStatus(
      lastSyncAt: DateTime.parse(json['lastSyncAt'] as String),
      pendingUpdates: json['pendingUpdates'] as int? ?? 0,
      failedSyncs: json['failedSyncs'] as int? ?? 0,
      isOnline: json['isOnline'] as bool? ?? true,
      lastError: json['lastError'] as String?,
    );
  }

  UpdateSyncStatus copyWith({
    DateTime? lastSyncAt,
    int? pendingUpdates,
    int? failedSyncs,
    bool? isOnline,
    String? lastError,
  }) {
    return UpdateSyncStatus(
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      pendingUpdates: pendingUpdates ?? this.pendingUpdates,
      failedSyncs: failedSyncs ?? this.failedSyncs,
      isOnline: isOnline ?? this.isOnline,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  List<Object?> get props => [
    lastSyncAt,
    pendingUpdates,
    failedSyncs,
    isOnline,
    lastError,
  ];
}
