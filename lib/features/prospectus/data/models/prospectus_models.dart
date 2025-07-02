import 'package:equatable/equatable.dart';

enum ProspectusSection {
  overview,
  admissionRequirements,
  courses,
  programs,
  fees,
  scholarships,
  facilities,
  faculty,
  calendar,
  policies,
  contact,
  other,
}

enum CourseLevel { certificate, diploma, undergraduate, postgraduate, doctoral }

enum CourseType { core, elective, prerequisite, corequisite }

class ProspectusDocument extends Equatable {
  final String id;
  final String institutionId;
  final String institutionName;
  final String title;
  final String academicYear;
  final DateTime publishedDate;
  final DateTime? lastUpdated;
  final String originalDocumentId;
  final Map<ProspectusSection, ProspectusContent> sections;
  final List<Course> courses;
  final List<Program> programs;
  final Map<String, dynamic> metadata;
  final bool isActive;

  const ProspectusDocument({
    required this.id,
    required this.institutionId,
    required this.institutionName,
    required this.title,
    required this.academicYear,
    required this.publishedDate,
    this.lastUpdated,
    required this.originalDocumentId,
    required this.sections,
    required this.courses,
    required this.programs,
    required this.metadata,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institutionId': institutionId,
      'institutionName': institutionName,
      'title': title,
      'academicYear': academicYear,
      'publishedDate': publishedDate.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'originalDocumentId': originalDocumentId,
      'sections': sections.map((k, v) => MapEntry(k.name, v.toJson())),
      'courses': courses.map((c) => c.toJson()).toList(),
      'programs': programs.map((p) => p.toJson()).toList(),
      'metadata': metadata,
      'isActive': isActive,
    };
  }

  factory ProspectusDocument.fromJson(Map<String, dynamic> json) {
    return ProspectusDocument(
      id: json['id'] as String,
      institutionId: json['institutionId'] as String,
      institutionName: json['institutionName'] as String,
      title: json['title'] as String,
      academicYear: json['academicYear'] as String,
      publishedDate: DateTime.parse(json['publishedDate'] as String),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      originalDocumentId: json['originalDocumentId'] as String,
      sections: (json['sections'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          ProspectusSection.values.firstWhere((s) => s.name == k),
          ProspectusContent.fromJson(v as Map<String, dynamic>),
        ),
      ),
      courses: (json['courses'] as List<dynamic>)
          .map((c) => Course.fromJson(c as Map<String, dynamic>))
          .toList(),
      programs: (json['programs'] as List<dynamic>)
          .map((p) => Program.fromJson(p as Map<String, dynamic>))
          .toList(),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  ProspectusDocument copyWith({
    String? id,
    String? institutionId,
    String? institutionName,
    String? title,
    String? academicYear,
    DateTime? publishedDate,
    DateTime? lastUpdated,
    String? originalDocumentId,
    Map<ProspectusSection, ProspectusContent>? sections,
    List<Course>? courses,
    List<Program>? programs,
    Map<String, dynamic>? metadata,
    bool? isActive,
  }) {
    return ProspectusDocument(
      id: id ?? this.id,
      institutionId: institutionId ?? this.institutionId,
      institutionName: institutionName ?? this.institutionName,
      title: title ?? this.title,
      academicYear: academicYear ?? this.academicYear,
      publishedDate: publishedDate ?? this.publishedDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      originalDocumentId: originalDocumentId ?? this.originalDocumentId,
      sections: sections ?? this.sections,
      courses: courses ?? this.courses,
      programs: programs ?? this.programs,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    institutionId,
    institutionName,
    title,
    academicYear,
    publishedDate,
    lastUpdated,
    originalDocumentId,
    sections,
    courses,
    programs,
    metadata,
    isActive,
  ];
}

class ProspectusContent extends Equatable {
  final ProspectusSection section;
  final String title;
  final String content;
  final String? summary;
  final List<String> keyPoints;
  final Map<String, String> translations;
  final int pageNumber;
  final Map<String, dynamic> metadata;

  const ProspectusContent({
    required this.section,
    required this.title,
    required this.content,
    this.summary,
    required this.keyPoints,
    required this.translations,
    required this.pageNumber,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'section': section.name,
      'title': title,
      'content': content,
      'summary': summary,
      'keyPoints': keyPoints,
      'translations': translations,
      'pageNumber': pageNumber,
      'metadata': metadata,
    };
  }

  factory ProspectusContent.fromJson(Map<String, dynamic> json) {
    return ProspectusContent(
      section: ProspectusSection.values.firstWhere(
        (s) => s.name == json['section'],
        orElse: () => ProspectusSection.other,
      ),
      title: json['title'] as String,
      content: json['content'] as String,
      summary: json['summary'] as String?,
      keyPoints: (json['keyPoints'] as List<dynamic>).cast<String>(),
      translations: Map<String, String>.from(json['translations'] as Map),
      pageNumber: json['pageNumber'] as int,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }

  ProspectusContent copyWith({
    ProspectusSection? section,
    String? title,
    String? content,
    String? summary,
    List<String>? keyPoints,
    Map<String, String>? translations,
    int? pageNumber,
    Map<String, dynamic>? metadata,
  }) {
    return ProspectusContent(
      section: section ?? this.section,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      keyPoints: keyPoints ?? this.keyPoints,
      translations: translations ?? this.translations,
      pageNumber: pageNumber ?? this.pageNumber,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    section,
    title,
    content,
    summary,
    keyPoints,
    translations,
    pageNumber,
    metadata,
  ];
}

class Course extends Equatable {
  final String id;
  final String code;
  final String title;
  final String description;
  final CourseLevel level;
  final CourseType type;
  final int credits;
  final List<String> prerequisites;
  final List<String> corequisites;
  final String? department;
  final String? faculty;
  final Map<String, String> translations;
  final Map<String, dynamic> metadata;

  const Course({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.level,
    required this.type,
    required this.credits,
    required this.prerequisites,
    required this.corequisites,
    this.department,
    this.faculty,
    required this.translations,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'level': level.name,
      'type': type.name,
      'credits': credits,
      'prerequisites': prerequisites,
      'corequisites': corequisites,
      'department': department,
      'faculty': faculty,
      'translations': translations,
      'metadata': metadata,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      level: CourseLevel.values.firstWhere(
        (l) => l.name == json['level'],
        orElse: () => CourseLevel.undergraduate,
      ),
      type: CourseType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => CourseType.core,
      ),
      credits: json['credits'] as int,
      prerequisites: (json['prerequisites'] as List<dynamic>).cast<String>(),
      corequisites: (json['corequisites'] as List<dynamic>).cast<String>(),
      department: json['department'] as String?,
      faculty: json['faculty'] as String?,
      translations: Map<String, String>.from(json['translations'] as Map),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }

  Course copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    CourseLevel? level,
    CourseType? type,
    int? credits,
    List<String>? prerequisites,
    List<String>? corequisites,
    String? department,
    String? faculty,
    Map<String, String>? translations,
    Map<String, dynamic>? metadata,
  }) {
    return Course(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      type: type ?? this.type,
      credits: credits ?? this.credits,
      prerequisites: prerequisites ?? this.prerequisites,
      corequisites: corequisites ?? this.corequisites,
      department: department ?? this.department,
      faculty: faculty ?? this.faculty,
      translations: translations ?? this.translations,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    code,
    title,
    description,
    level,
    type,
    credits,
    prerequisites,
    corequisites,
    department,
    faculty,
    translations,
    metadata,
  ];
}

class Program extends Equatable {
  final String id;
  final String name;
  final String description;
  final CourseLevel level;
  final String? department;
  final String? faculty;
  final int durationYears;
  final int totalCredits;
  final List<String> requiredCourses;
  final List<String> electiveCourses;
  final Map<String, dynamic> admissionRequirements;
  final Map<String, double> fees;
  final Map<String, String> translations;
  final Map<String, dynamic> metadata;

  const Program({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    this.department,
    this.faculty,
    required this.durationYears,
    required this.totalCredits,
    required this.requiredCourses,
    required this.electiveCourses,
    required this.admissionRequirements,
    required this.fees,
    required this.translations,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'level': level.name,
      'department': department,
      'faculty': faculty,
      'durationYears': durationYears,
      'totalCredits': totalCredits,
      'requiredCourses': requiredCourses,
      'electiveCourses': electiveCourses,
      'admissionRequirements': admissionRequirements,
      'fees': fees,
      'translations': translations,
      'metadata': metadata,
    };
  }

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      level: CourseLevel.values.firstWhere(
        (l) => l.name == json['level'],
        orElse: () => CourseLevel.undergraduate,
      ),
      department: json['department'] as String?,
      faculty: json['faculty'] as String?,
      durationYears: json['durationYears'] as int,
      totalCredits: json['totalCredits'] as int,
      requiredCourses: (json['requiredCourses'] as List<dynamic>)
          .cast<String>(),
      electiveCourses: (json['electiveCourses'] as List<dynamic>)
          .cast<String>(),
      admissionRequirements: Map<String, dynamic>.from(
        json['admissionRequirements'] as Map,
      ),
      fees: Map<String, double>.from(json['fees'] as Map),
      translations: Map<String, String>.from(json['translations'] as Map),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    level,
    department,
    faculty,
    durationYears,
    totalCredits,
    requiredCourses,
    electiveCourses,
    admissionRequirements,
    fees,
    translations,
    metadata,
  ];
}
