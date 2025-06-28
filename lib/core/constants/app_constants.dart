class AppConstants {
  // App Information
  static const String appName = 'VIA - Voice Interactive Assistant';
  static const String appVersion = '1.0.0';
  
  // Supported Languages
  static const String englishLocale = 'en';
  static const String swahiliLocale = 'sw';
  
  // Firebase Collections
  static const String documentsCollection = 'documents';
  static const String usersCollection = 'users';
  static const String userPreferencesCollection = 'user_preferences';
  
  // Voice Commands
  static const List<String> englishCommands = [
    'read document',
    'open document',
    'read section',
    'stop reading',
    'pause reading',
    'resume reading',
    'next page',
    'previous page',
    'go to page',
    'list documents',
    'upload document',
    'delete document',
    'change language',
    'settings',
    'help',
  ];
  
  static const List<String> swahiliCommands = [
    'soma hati',
    'fungua hati',
    'soma sehemu',
    'acha kusoma',
    'simamisha kusoma',
    'endelea kusoma',
    'ukurasa unaofuata',
    'ukurasa uliotangulia',
    'nenda ukurasa',
    'orodha ya hati',
    'pakia hati',
    'futa hati',
    'badilisha lugha',
    'mipangilio',
    'msaada',
  ];
  
  // TTS Settings
  static const double defaultSpeechRate = 0.5;
  static const double defaultPitch = 1.0;
  static const double defaultVolume = 1.0;
  
  // File Types
  static const List<String> supportedFileTypes = ['pdf'];
  static const int maxFileSizeInMB = 50;
  
  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection';
  static const String permissionDeniedMessage = 'Permission denied. Please grant required permissions';
  static const String fileNotFoundMessage = 'File not found';
  static const String unsupportedFileTypeMessage = 'Unsupported file type';
  static const String fileTooLargeMessage = 'File size exceeds maximum limit';
}
