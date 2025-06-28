import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/localization_helper.dart';
import '../entities/voice_command.dart';
import '../../../documents/domain/entities/document.dart';
import '../../../documents/domain/usecases/get_documents.dart';
import '../../../settings/domain/usecases/set_language_preference.dart';
import '../../../settings/domain/usecases/get_language_preference.dart';

class ProcessVoiceCommand implements UseCase<VoiceCommandResult, ProcessVoiceCommandParams> {
  final GetDocuments _getDocuments;
  final SetLanguagePreference _setLanguagePreference;
  final GetLanguagePreference _getLanguagePreference;

  ProcessVoiceCommand(
    this._getDocuments,
    this._setLanguagePreference,
    this._getLanguagePreference,
  );

  @override
  Future<Either<Failure, VoiceCommandResult>> call(ProcessVoiceCommandParams params) async {
    try {
      final command = params.voiceCommand;
      
      switch (command.type) {
        case VoiceCommandType.readDocument:
          return await _handleReadDocument(params);
        
        case VoiceCommandType.openDocument:
          return await _handleOpenDocument(params);
        
        case VoiceCommandType.readSection:
          return await _handleReadSection(params);
        
        case VoiceCommandType.stopReading:
          return Right(VoiceCommandResult.action(
            action: VoiceCommandAction.stopReading,
            message: LocalizationHelper.getVoicePrompt('readingStopped', command.language),
          ));
        
        case VoiceCommandType.pauseReading:
          return Right(VoiceCommandResult.action(
            action: VoiceCommandAction.pauseReading,
            message: LocalizationHelper.getVoicePrompt('readingPaused', command.language),
          ));
        
        case VoiceCommandType.resumeReading:
          return Right(VoiceCommandResult.action(
            action: VoiceCommandAction.resumeReading,
            message: LocalizationHelper.getVoicePrompt('readingResumed', command.language),
          ));
        
        case VoiceCommandType.nextPage:
          return Right(VoiceCommandResult.action(
            action: VoiceCommandAction.nextPage,
            message: 'Going to next page',
          ));
        
        case VoiceCommandType.previousPage:
          return Right(VoiceCommandResult.action(
            action: VoiceCommandAction.previousPage,
            message: 'Going to previous page',
          ));
        
        case VoiceCommandType.goToPage:
          return await _handleGoToPage(params);
        
        case VoiceCommandType.listDocuments:
          return await _handleListDocuments(params);
        
        case VoiceCommandType.uploadDocument:
          return Right(VoiceCommandResult.navigation(
            route: '/upload',
            message: 'Opening document upload',
          ));
        
        case VoiceCommandType.deleteDocument:
          return await _handleDeleteDocument(params);
        
        case VoiceCommandType.changeLanguage:
          return await _handleChangeLanguage(params);
        
        case VoiceCommandType.settings:
          return Right(VoiceCommandResult.navigation(
            route: '/settings',
            message: LocalizationHelper.getVoicePrompt('settingsOpened', command.language),
          ));
        
        case VoiceCommandType.help:
          return await _handleHelp(params);
        
        case VoiceCommandType.unknown:
        default:
          return Right(VoiceCommandResult.error(
            message: LocalizationHelper.getVoicePrompt('commandNotRecognized', command.language),
          ));
      }
    } catch (e) {
      return Left(SpeechRecognitionFailure('Failed to process voice command: $e'));
    }
  }

  Future<Either<Failure, VoiceCommandResult>> _handleReadDocument(
    ProcessVoiceCommandParams params,
  ) async {
    final command = params.voiceCommand;
    
    if (params.currentDocument != null) {
      return Right(VoiceCommandResult.action(
        action: VoiceCommandAction.readDocument,
        data: {'document': params.currentDocument},
        message: LocalizationHelper.getVoicePrompt('readingStarted', command.language),
      ));
    }
    
    // If no current document, try to find one by name
    final documentsResult = await _getDocuments(NoParams());
    
    return documentsResult.fold(
      (failure) => Left(failure),
      (documents) {
        if (documents.isEmpty) {
          return Right(VoiceCommandResult.error(
            message: 'No documents available to read',
          ));
        }
        
        // Use the most recently accessed document
        final sortedDocs = List<Document>.from(documents);
        sortedDocs.sort((a, b) => b.lastAccessedAt.compareTo(a.lastAccessedAt));
        
        return Right(VoiceCommandResult.action(
          action: VoiceCommandAction.readDocument,
          data: {'document': sortedDocs.first},
          message: 'Reading ${sortedDocs.first.title}',
        ));
      },
    );
  }

  Future<Either<Failure, VoiceCommandResult>> _handleOpenDocument(
    ProcessVoiceCommandParams params,
  ) async {
    final command = params.voiceCommand;
    final documentName = command.parameters['documentName'] as String?;
    
    final documentsResult = await _getDocuments(NoParams());
    
    return documentsResult.fold(
      (failure) => Left(failure),
      (documents) {
        if (documents.isEmpty) {
          return Right(VoiceCommandResult.error(
            message: 'No documents available',
          ));
        }
        
        Document? targetDocument;
        
        if (documentName != null) {
          // Find document by name (fuzzy matching)
          targetDocument = _findDocumentByName(documents, documentName);
        }
        
        // If no specific document found, use the most recent
        targetDocument ??= documents.reduce((a, b) => 
          a.lastAccessedAt.isAfter(b.lastAccessedAt) ? a : b);
        
        return Right(VoiceCommandResult.action(
          action: VoiceCommandAction.openDocument,
          data: {'document': targetDocument},
          message: LocalizationHelper.getVoicePrompt('documentOpened', command.language),
        ));
      },
    );
  }

  Future<Either<Failure, VoiceCommandResult>> _handleReadSection(
    ProcessVoiceCommandParams params,
  ) async {
    final command = params.voiceCommand;
    final sectionName = command.parameters['sectionName'] as String?;
    
    if (params.currentDocument == null) {
      return Right(VoiceCommandResult.error(
        message: 'No document is currently open',
      ));
    }
    
    return Right(VoiceCommandResult.action(
      action: VoiceCommandAction.readSection,
      data: {
        'document': params.currentDocument,
        'sectionName': sectionName,
      },
      message: 'Reading section: ${sectionName ?? "current section"}',
    ));
  }

  Future<Either<Failure, VoiceCommandResult>> _handleGoToPage(
    ProcessVoiceCommandParams params,
  ) async {
    final command = params.voiceCommand;
    final pageNumber = command.parameters['pageNumber'] as int?;
    
    if (pageNumber == null) {
      return Right(VoiceCommandResult.error(
        message: 'Please specify a page number',
      ));
    }
    
    return Right(VoiceCommandResult.action(
      action: VoiceCommandAction.goToPage,
      data: {'pageNumber': pageNumber},
      message: 'Going to page $pageNumber',
    ));
  }

  Future<Either<Failure, VoiceCommandResult>> _handleListDocuments(
    ProcessVoiceCommandParams params,
  ) async {
    final documentsResult = await _getDocuments(NoParams());
    
    return documentsResult.fold(
      (failure) => Left(failure),
      (documents) {
        if (documents.isEmpty) {
          return Right(VoiceCommandResult.speech(
            message: 'You have no documents',
          ));
        }
        
        final documentList = documents.take(5).map((doc) => doc.title).join(', ');
        final message = documents.length <= 5
            ? 'Your documents are: $documentList'
            : 'Your recent documents are: $documentList, and ${documents.length - 5} more';
        
        return Right(VoiceCommandResult.speech(
          message: message,
          data: {'documents': documents},
        ));
      },
    );
  }

  Future<Either<Failure, VoiceCommandResult>> _handleDeleteDocument(
    ProcessVoiceCommandParams params,
  ) async {
    final command = params.voiceCommand;
    final documentName = command.parameters['documentName'] as String?;
    
    if (documentName == null && params.currentDocument == null) {
      return Right(VoiceCommandResult.error(
        message: 'Please specify which document to delete',
      ));
    }
    
    final targetDocument = params.currentDocument;
    
    return Right(VoiceCommandResult.confirmation(
      action: VoiceCommandAction.deleteDocument,
      data: {'document': targetDocument},
      message: 'Are you sure you want to delete ${targetDocument?.title ?? documentName}?',
    ));
  }

  Future<Either<Failure, VoiceCommandResult>> _handleChangeLanguage(
    ProcessVoiceCommandParams params,
  ) async {
    final currentLangResult = await _getLanguagePreference(NoParams());
    
    return currentLangResult.fold(
      (failure) => Left(failure),
      (currentLang) {
        final newLang = currentLang == 'en' ? 'sw' : 'en';
        
        return Right(VoiceCommandResult.action(
          action: VoiceCommandAction.changeLanguage,
          data: {'language': newLang},
          message: LocalizationHelper.getVoicePrompt('languageChanged', newLang),
        ));
      },
    );
  }

  Future<Either<Failure, VoiceCommandResult>> _handleHelp(
    ProcessVoiceCommandParams params,
  ) async {
    final command = params.voiceCommand;
    final helpMessage = _getHelpMessage(command.language);
    
    return Right(VoiceCommandResult.speech(
      message: helpMessage,
    ));
  }

  Document? _findDocumentByName(List<Document> documents, String name) {
    final normalizedName = name.toLowerCase();
    
    // Exact match first
    for (final doc in documents) {
      if (doc.title.toLowerCase() == normalizedName) {
        return doc;
      }
    }
    
    // Partial match
    for (final doc in documents) {
      if (doc.title.toLowerCase().contains(normalizedName) ||
          normalizedName.contains(doc.title.toLowerCase())) {
        return doc;
      }
    }
    
    return null;
  }

  String _getHelpMessage(String language) {
    if (language == 'sw') {
      return 'Unaweza kusema: soma hati, fungua hati, acha kusoma, ukurasa unaofuata, ukurasa uliotangulia, badilisha lugha, mipangilio, na msaada.';
    } else {
      return 'You can say: read document, open document, stop reading, next page, previous page, change language, settings, and help.';
    }
  }
}

class ProcessVoiceCommandParams extends Equatable {
  final VoiceCommand voiceCommand;
  final Document? currentDocument;
  final int? currentPage;
  final Map<String, dynamic>? context;

  const ProcessVoiceCommandParams({
    required this.voiceCommand,
    this.currentDocument,
    this.currentPage,
    this.context,
  });

  @override
  List<Object?> get props => [voiceCommand, currentDocument, currentPage, context];
}

class VoiceCommandResult extends Equatable {
  final VoiceCommandResultType type;
  final VoiceCommandAction? action;
  final String? route;
  final String message;
  final Map<String, dynamic>? data;
  final bool requiresConfirmation;

  const VoiceCommandResult({
    required this.type,
    this.action,
    this.route,
    required this.message,
    this.data,
    this.requiresConfirmation = false,
  });

  factory VoiceCommandResult.action({
    required VoiceCommandAction action,
    required String message,
    Map<String, dynamic>? data,
  }) {
    return VoiceCommandResult(
      type: VoiceCommandResultType.action,
      action: action,
      message: message,
      data: data,
    );
  }

  factory VoiceCommandResult.navigation({
    required String route,
    required String message,
    Map<String, dynamic>? data,
  }) {
    return VoiceCommandResult(
      type: VoiceCommandResultType.navigation,
      route: route,
      message: message,
      data: data,
    );
  }

  factory VoiceCommandResult.speech({
    required String message,
    Map<String, dynamic>? data,
  }) {
    return VoiceCommandResult(
      type: VoiceCommandResultType.speech,
      message: message,
      data: data,
    );
  }

  factory VoiceCommandResult.confirmation({
    required VoiceCommandAction action,
    required String message,
    Map<String, dynamic>? data,
  }) {
    return VoiceCommandResult(
      type: VoiceCommandResultType.confirmation,
      action: action,
      message: message,
      data: data,
      requiresConfirmation: true,
    );
  }

  factory VoiceCommandResult.error({
    required String message,
  }) {
    return VoiceCommandResult(
      type: VoiceCommandResultType.error,
      message: message,
    );
  }

  @override
  List<Object?> get props => [type, action, route, message, data, requiresConfirmation];
}

enum VoiceCommandResultType {
  action,
  navigation,
  speech,
  confirmation,
  error,
}

enum VoiceCommandAction {
  readDocument,
  openDocument,
  readSection,
  stopReading,
  pauseReading,
  resumeReading,
  nextPage,
  previousPage,
  goToPage,
  deleteDocument,
  changeLanguage,
}
