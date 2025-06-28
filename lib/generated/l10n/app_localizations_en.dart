// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'VIA - Voice Interactive Assistant';

  @override
  String get welcome => 'Welcome to VIA';

  @override
  String get documents => 'Documents';

  @override
  String get settings => 'Settings';

  @override
  String get uploadDocument => 'Upload Document';

  @override
  String get deleteDocument => 'Delete Document';

  @override
  String get openDocument => 'Open Document';

  @override
  String get readDocument => 'Read Document';

  @override
  String get stopReading => 'Stop Reading';

  @override
  String get pauseReading => 'Pause Reading';

  @override
  String get resumeReading => 'Resume Reading';

  @override
  String get nextPage => 'Next Page';

  @override
  String get previousPage => 'Previous Page';

  @override
  String get goToPage => 'Go to Page';

  @override
  String pageNumber(int number) {
    return 'Page $number';
  }

  @override
  String totalPages(int total) {
    return '$total pages';
  }

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get swahili => 'Swahili';

  @override
  String get speechSettings => 'Speech Settings';

  @override
  String get speechRate => 'Speech Rate';

  @override
  String get pitch => 'Pitch';

  @override
  String get volume => 'Volume';

  @override
  String get accessibilitySettings => 'Accessibility Settings';

  @override
  String get highContrastMode => 'High Contrast Mode';

  @override
  String get textSize => 'Text Size';

  @override
  String get voiceFeedback => 'Voice Feedback';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get voiceCommands => 'Voice Commands';

  @override
  String get startListening => 'Start Listening';

  @override
  String get stopListening => 'Stop Listening';

  @override
  String get listening => 'Listening...';

  @override
  String get speakCommand => 'Speak a command';

  @override
  String get commandNotRecognized => 'Command not recognized';

  @override
  String get noDocuments => 'No documents found';

  @override
  String get uploadingDocument => 'Uploading document...';

  @override
  String get documentUploaded => 'Document uploaded successfully';

  @override
  String get documentDeleted => 'Document deleted successfully';

  @override
  String get error => 'Error';

  @override
  String get networkError => 'Please check your internet connection';

  @override
  String get permissionDenied =>
      'Permission denied. Please grant required permissions';

  @override
  String get fileNotFound => 'File not found';

  @override
  String get unsupportedFileType => 'Unsupported file type';

  @override
  String get fileTooLarge => 'File size exceeds maximum limit';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';
}
