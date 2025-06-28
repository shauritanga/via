import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';
import '../constants/app_constants.dart';

class LocalizationHelper {
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  static String getErrorMessage(String errorKey, BuildContext context) {
    final localizations = of(context);
    
    switch (errorKey) {
      case AppConstants.networkErrorMessage:
        return localizations.networkError;
      case AppConstants.permissionDeniedMessage:
        return localizations.permissionDenied;
      case AppConstants.fileNotFoundMessage:
        return localizations.fileNotFound;
      case AppConstants.unsupportedFileTypeMessage:
        return localizations.unsupportedFileType;
      case AppConstants.fileTooLargeMessage:
        return localizations.fileTooLarge;
      default:
        return localizations.error;
    }
  }

  static String getVoiceCommandText(String commandKey, BuildContext context) {
    final localizations = of(context);
    
    switch (commandKey) {
      case 'readDocument':
        return localizations.readDocument;
      case 'openDocument':
        return localizations.openDocument;
      case 'stopReading':
        return localizations.stopReading;
      case 'pauseReading':
        return localizations.pauseReading;
      case 'resumeReading':
        return localizations.resumeReading;
      case 'nextPage':
        return localizations.nextPage;
      case 'previousPage':
        return localizations.previousPage;
      case 'goToPage':
        return localizations.goToPage;
      case 'listDocuments':
        return localizations.documents;
      case 'uploadDocument':
        return localizations.uploadDocument;
      case 'deleteDocument':
        return localizations.deleteDocument;
      case 'settings':
        return localizations.settings;
      case 'help':
        return localizations.help;
      default:
        return commandKey;
    }
  }

  static List<String> getLocalizedVoiceCommands(String languageCode) {
    if (languageCode == AppConstants.swahiliLocale) {
      return AppConstants.swahiliCommands;
    }
    return AppConstants.englishCommands;
  }

  static String formatPageNumber(int pageNumber, BuildContext context) {
    final localizations = of(context);
    return localizations.pageNumber(pageNumber);
  }

  static String formatTotalPages(int totalPages, BuildContext context) {
    final localizations = of(context);
    return localizations.totalPages(totalPages);
  }

  static TextDirection getTextDirection(String languageCode) {
    // Both English and Swahili are LTR languages
    return TextDirection.ltr;
  }

  static bool isRightToLeft(String languageCode) {
    // Neither English nor Swahili are RTL languages
    return false;
  }

  static String getLocalizedDateFormat(String languageCode) {
    switch (languageCode) {
      case AppConstants.swahiliLocale:
        return 'dd/MM/yyyy'; // Common format in East Africa
      case AppConstants.englishLocale:
      default:
        return 'MM/dd/yyyy'; // US format
    }
  }

  static String getLocalizedTimeFormat(String languageCode) {
    switch (languageCode) {
      case AppConstants.swahiliLocale:
        return 'HH:mm'; // 24-hour format
      case AppConstants.englishLocale:
      default:
        return 'h:mm a'; // 12-hour format with AM/PM
    }
  }

  static String getVoicePrompt(String promptKey, String languageCode) {
    if (languageCode == AppConstants.swahiliLocale) {
      return _getSwahiliVoicePrompt(promptKey);
    }
    return _getEnglishVoicePrompt(promptKey);
  }

  static String _getEnglishVoicePrompt(String promptKey) {
    switch (promptKey) {
      case 'welcome':
        return 'Welcome to VIA. Say "help" to hear available commands.';
      case 'listening':
        return 'Listening for your command...';
      case 'commandExecuted':
        return 'Command executed successfully.';
      case 'commandNotRecognized':
        return 'Sorry, I didn\'t understand that command. Say "help" for available commands.';
      case 'documentOpened':
        return 'Document opened. Say "read document" to start reading.';
      case 'readingStarted':
        return 'Starting to read the document.';
      case 'readingPaused':
        return 'Reading paused. Say "resume" to continue.';
      case 'readingStopped':
        return 'Reading stopped.';
      case 'languageChanged':
        return 'Language changed successfully.';
      case 'settingsOpened':
        return 'Settings opened.';
      default:
        return promptKey;
    }
  }

  static String _getSwahiliVoicePrompt(String promptKey) {
    switch (promptKey) {
      case 'welcome':
        return 'Karibu VIA. Sema "msaada" kusikia amri zinazopatikana.';
      case 'listening':
        return 'Ninasikiliza amri yako...';
      case 'commandExecuted':
        return 'Amri imetekelezwa kwa mafanikio.';
      case 'commandNotRecognized':
        return 'Samahani, sikuelewa amri hiyo. Sema "msaada" kwa amri zinazopatikana.';
      case 'documentOpened':
        return 'Hati imefunguliwa. Sema "soma hati" kuanza kusoma.';
      case 'readingStarted':
        return 'Ninaanza kusoma hati.';
      case 'readingPaused':
        return 'Kusoma kumesimamishwa. Sema "endelea" kuendelea.';
      case 'readingStopped':
        return 'Kusoma kumeacha.';
      case 'languageChanged':
        return 'Lugha imebadilishwa kwa mafanikio.';
      case 'settingsOpened':
        return 'Mipangilio imefunguliwa.';
      default:
        return promptKey;
    }
  }
}
