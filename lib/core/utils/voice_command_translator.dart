import '../constants/app_constants.dart';
import '../../features/voice_commands/domain/entities/voice_command.dart';

class VoiceCommandTranslator {
  static const Map<String, Map<String, VoiceCommandType>> _commandMappings = {
    AppConstants.englishLocale: {
      'read document': VoiceCommandType.readDocument,
      'read the document': VoiceCommandType.readDocument,
      'start reading': VoiceCommandType.readDocument,
      'open document': VoiceCommandType.openDocument,
      'open the document': VoiceCommandType.openDocument,
      'read section': VoiceCommandType.readSection,
      'read this section': VoiceCommandType.readSection,
      'stop reading': VoiceCommandType.stopReading,
      'stop': VoiceCommandType.stopReading,
      'pause reading': VoiceCommandType.pauseReading,
      'pause': VoiceCommandType.pauseReading,
      'resume reading': VoiceCommandType.resumeReading,
      'resume': VoiceCommandType.resumeReading,
      'continue': VoiceCommandType.resumeReading,
      'next page': VoiceCommandType.nextPage,
      'go to next page': VoiceCommandType.nextPage,
      'previous page': VoiceCommandType.previousPage,
      'go to previous page': VoiceCommandType.previousPage,
      'go to page': VoiceCommandType.goToPage,
      'page': VoiceCommandType.goToPage,
      'list documents': VoiceCommandType.listDocuments,
      'show documents': VoiceCommandType.listDocuments,
      'my documents': VoiceCommandType.listDocuments,
      'upload document': VoiceCommandType.uploadDocument,
      'add document': VoiceCommandType.uploadDocument,
      'delete document': VoiceCommandType.deleteDocument,
      'remove document': VoiceCommandType.deleteDocument,
      'change language': VoiceCommandType.changeLanguage,
      'switch language': VoiceCommandType.changeLanguage,
      'settings': VoiceCommandType.settings,
      'open settings': VoiceCommandType.settings,
      'help': VoiceCommandType.help,
      'show help': VoiceCommandType.help,
    },
    AppConstants.swahiliLocale: {
      'soma hati': VoiceCommandType.readDocument,
      'soma hiyo hati': VoiceCommandType.readDocument,
      'anza kusoma': VoiceCommandType.readDocument,
      'fungua hati': VoiceCommandType.openDocument,
      'fungua hiyo hati': VoiceCommandType.openDocument,
      'soma sehemu': VoiceCommandType.readSection,
      'soma sehemu hii': VoiceCommandType.readSection,
      'acha kusoma': VoiceCommandType.stopReading,
      'simama': VoiceCommandType.stopReading,
      'simamisha kusoma': VoiceCommandType.pauseReading,
      'simamisha': VoiceCommandType.pauseReading,
      'endelea kusoma': VoiceCommandType.resumeReading,
      'endelea': VoiceCommandType.resumeReading,
      'ukurasa unaofuata': VoiceCommandType.nextPage,
      'nenda ukurasa unaofuata': VoiceCommandType.nextPage,
      'ukurasa uliotangulia': VoiceCommandType.previousPage,
      'nenda ukurasa uliotangulia': VoiceCommandType.previousPage,
      'nenda ukurasa': VoiceCommandType.goToPage,
      'ukurasa': VoiceCommandType.goToPage,
      'orodha ya hati': VoiceCommandType.listDocuments,
      'onyesha hati': VoiceCommandType.listDocuments,
      'hati zangu': VoiceCommandType.listDocuments,
      'pakia hati': VoiceCommandType.uploadDocument,
      'ongeza hati': VoiceCommandType.uploadDocument,
      'futa hati': VoiceCommandType.deleteDocument,
      'ondoa hati': VoiceCommandType.deleteDocument,
      'badilisha lugha': VoiceCommandType.changeLanguage,
      'geuza lugha': VoiceCommandType.changeLanguage,
      'mipangilio': VoiceCommandType.settings,
      'fungua mipangilio': VoiceCommandType.settings,
      'msaada': VoiceCommandType.help,
      'onyesha msaada': VoiceCommandType.help,
    },
  };

  static VoiceCommand parseCommand({
    required String recognizedText,
    required String language,
    required double confidence,
  }) {
    final normalizedText = recognizedText.toLowerCase().trim();
    final commandMappings = _commandMappings[language] ?? _commandMappings[AppConstants.englishLocale]!;
    
    VoiceCommandType commandType = VoiceCommandType.unknown;
    Map<String, dynamic> parameters = {};

    // Direct command matching
    if (commandMappings.containsKey(normalizedText)) {
      commandType = commandMappings[normalizedText]!;
    } else {
      // Pattern matching for commands with parameters
      commandType = _matchCommandPatterns(normalizedText, language, parameters);
    }

    return VoiceCommand(
      command: recognizedText,
      type: commandType,
      parameters: parameters,
      language: language,
      confidence: confidence,
      timestamp: DateTime.now(),
    );
  }

  static VoiceCommandType _matchCommandPatterns(
    String text,
    String language,
    Map<String, dynamic> parameters,
  ) {
    if (language == AppConstants.englishLocale) {
      return _matchEnglishPatterns(text, parameters);
    } else if (language == AppConstants.swahiliLocale) {
      return _matchSwahiliPatterns(text, parameters);
    }
    return VoiceCommandType.unknown;
  }

  static VoiceCommandType _matchEnglishPatterns(
    String text,
    Map<String, dynamic> parameters,
  ) {
    // Go to page number
    final pageRegex = RegExp(r'(?:go to page|page)\s+(\d+)', caseSensitive: false);
    final pageMatch = pageRegex.firstMatch(text);
    if (pageMatch != null) {
      parameters['pageNumber'] = int.tryParse(pageMatch.group(1)!) ?? 1;
      return VoiceCommandType.goToPage;
    }

    // Read section by name/number
    final sectionRegex = RegExp(r'read section\s+(.+)', caseSensitive: false);
    final sectionMatch = sectionRegex.firstMatch(text);
    if (sectionMatch != null) {
      parameters['sectionName'] = sectionMatch.group(1)!.trim();
      return VoiceCommandType.readSection;
    }

    // Open document by name
    final openDocRegex = RegExp(r'open (?:document\s+)?(.+)', caseSensitive: false);
    final openDocMatch = openDocRegex.firstMatch(text);
    if (openDocMatch != null && !text.contains('settings')) {
      parameters['documentName'] = openDocMatch.group(1)!.trim();
      return VoiceCommandType.openDocument;
    }

    return VoiceCommandType.unknown;
  }

  static VoiceCommandType _matchSwahiliPatterns(
    String text,
    Map<String, dynamic> parameters,
  ) {
    // Nenda ukurasa nambari
    final pageRegex = RegExp(r'(?:nenda ukurasa|ukurasa)\s+(\d+)', caseSensitive: false);
    final pageMatch = pageRegex.firstMatch(text);
    if (pageMatch != null) {
      parameters['pageNumber'] = int.tryParse(pageMatch.group(1)!) ?? 1;
      return VoiceCommandType.goToPage;
    }

    // Soma sehemu kwa jina/nambari
    final sectionRegex = RegExp(r'soma sehemu\s+(.+)', caseSensitive: false);
    final sectionMatch = sectionRegex.firstMatch(text);
    if (sectionMatch != null) {
      parameters['sectionName'] = sectionMatch.group(1)!.trim();
      return VoiceCommandType.readSection;
    }

    // Fungua hati kwa jina
    final openDocRegex = RegExp(r'fungua (?:hati\s+)?(.+)', caseSensitive: false);
    final openDocMatch = openDocRegex.firstMatch(text);
    if (openDocMatch != null && !text.contains('mipangilio')) {
      parameters['documentName'] = openDocMatch.group(1)!.trim();
      return VoiceCommandType.openDocument;
    }

    return VoiceCommandType.unknown;
  }

  static List<String> getAvailableCommands(String language) {
    final commandMappings = _commandMappings[language] ?? _commandMappings[AppConstants.englishLocale]!;
    return commandMappings.keys.toList();
  }

  static String getCommandDescription(VoiceCommandType commandType, String language) {
    if (language == AppConstants.swahiliLocale) {
      return _getSwahiliCommandDescription(commandType);
    }
    return _getEnglishCommandDescription(commandType);
  }

  static String _getEnglishCommandDescription(VoiceCommandType commandType) {
    switch (commandType) {
      case VoiceCommandType.readDocument:
        return 'Start reading the current document';
      case VoiceCommandType.openDocument:
        return 'Open a specific document';
      case VoiceCommandType.readSection:
        return 'Read a specific section';
      case VoiceCommandType.stopReading:
        return 'Stop reading';
      case VoiceCommandType.pauseReading:
        return 'Pause reading';
      case VoiceCommandType.resumeReading:
        return 'Resume reading';
      case VoiceCommandType.nextPage:
        return 'Go to next page';
      case VoiceCommandType.previousPage:
        return 'Go to previous page';
      case VoiceCommandType.goToPage:
        return 'Go to a specific page';
      case VoiceCommandType.listDocuments:
        return 'List all documents';
      case VoiceCommandType.uploadDocument:
        return 'Upload a new document';
      case VoiceCommandType.deleteDocument:
        return 'Delete a document';
      case VoiceCommandType.changeLanguage:
        return 'Change app language';
      case VoiceCommandType.settings:
        return 'Open settings';
      case VoiceCommandType.help:
        return 'Show help';
      default:
        return 'Unknown command';
    }
  }

  static String _getSwahiliCommandDescription(VoiceCommandType commandType) {
    switch (commandType) {
      case VoiceCommandType.readDocument:
        return 'Anza kusoma hati ya sasa';
      case VoiceCommandType.openDocument:
        return 'Fungua hati maalum';
      case VoiceCommandType.readSection:
        return 'Soma sehemu maalum';
      case VoiceCommandType.stopReading:
        return 'Acha kusoma';
      case VoiceCommandType.pauseReading:
        return 'Simamisha kusoma';
      case VoiceCommandType.resumeReading:
        return 'Endelea kusoma';
      case VoiceCommandType.nextPage:
        return 'Nenda ukurasa unaofuata';
      case VoiceCommandType.previousPage:
        return 'Nenda ukurasa uliotangulia';
      case VoiceCommandType.goToPage:
        return 'Nenda ukurasa maalum';
      case VoiceCommandType.listDocuments:
        return 'Orodhesha hati zote';
      case VoiceCommandType.uploadDocument:
        return 'Pakia hati mpya';
      case VoiceCommandType.deleteDocument:
        return 'Futa hati';
      case VoiceCommandType.changeLanguage:
        return 'Badilisha lugha ya programu';
      case VoiceCommandType.settings:
        return 'Fungua mipangilio';
      case VoiceCommandType.help:
        return 'Onyesha msaada';
      default:
        return 'Amri isiyojulikana';
    }
  }
}
