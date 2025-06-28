import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'VIA - Voice Interactive Assistant'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome to VIA'**
  String get welcome;

  /// Documents section title
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// Settings section title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Upload document button text
  ///
  /// In en, this message translates to:
  /// **'Upload Document'**
  String get uploadDocument;

  /// Delete document button text
  ///
  /// In en, this message translates to:
  /// **'Delete Document'**
  String get deleteDocument;

  /// Open document button text
  ///
  /// In en, this message translates to:
  /// **'Open Document'**
  String get openDocument;

  /// Read document button text
  ///
  /// In en, this message translates to:
  /// **'Read Document'**
  String get readDocument;

  /// Stop reading button text
  ///
  /// In en, this message translates to:
  /// **'Stop Reading'**
  String get stopReading;

  /// Pause reading button text
  ///
  /// In en, this message translates to:
  /// **'Pause Reading'**
  String get pauseReading;

  /// Resume reading button text
  ///
  /// In en, this message translates to:
  /// **'Resume Reading'**
  String get resumeReading;

  /// Next page button text
  ///
  /// In en, this message translates to:
  /// **'Next Page'**
  String get nextPage;

  /// Previous page button text
  ///
  /// In en, this message translates to:
  /// **'Previous Page'**
  String get previousPage;

  /// Go to page button text
  ///
  /// In en, this message translates to:
  /// **'Go to Page'**
  String get goToPage;

  /// Page number display
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String pageNumber(int number);

  /// Total pages display
  ///
  /// In en, this message translates to:
  /// **'{total} pages'**
  String totalPages(int total);

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Swahili language option
  ///
  /// In en, this message translates to:
  /// **'Swahili'**
  String get swahili;

  /// Speech settings section title
  ///
  /// In en, this message translates to:
  /// **'Speech Settings'**
  String get speechSettings;

  /// Speech rate setting label
  ///
  /// In en, this message translates to:
  /// **'Speech Rate'**
  String get speechRate;

  /// Pitch setting label
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get pitch;

  /// Volume setting label
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// Accessibility settings section title
  ///
  /// In en, this message translates to:
  /// **'Accessibility Settings'**
  String get accessibilitySettings;

  /// High contrast mode setting
  ///
  /// In en, this message translates to:
  /// **'High Contrast Mode'**
  String get highContrastMode;

  /// Text size setting
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// Voice feedback setting
  ///
  /// In en, this message translates to:
  /// **'Voice Feedback'**
  String get voiceFeedback;

  /// Haptic feedback setting
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// Voice commands section title
  ///
  /// In en, this message translates to:
  /// **'Voice Commands'**
  String get voiceCommands;

  /// Start listening button text
  ///
  /// In en, this message translates to:
  /// **'Start Listening'**
  String get startListening;

  /// Stop listening button text
  ///
  /// In en, this message translates to:
  /// **'Stop Listening'**
  String get stopListening;

  /// Listening status text
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// Instruction to speak a command
  ///
  /// In en, this message translates to:
  /// **'Speak a command'**
  String get speakCommand;

  /// Error message for unrecognized command
  ///
  /// In en, this message translates to:
  /// **'Command not recognized'**
  String get commandNotRecognized;

  /// Message when no documents are available
  ///
  /// In en, this message translates to:
  /// **'No documents found'**
  String get noDocuments;

  /// Status message during document upload
  ///
  /// In en, this message translates to:
  /// **'Uploading document...'**
  String get uploadingDocument;

  /// Success message after document upload
  ///
  /// In en, this message translates to:
  /// **'Document uploaded successfully'**
  String get documentUploaded;

  /// Success message after document deletion
  ///
  /// In en, this message translates to:
  /// **'Document deleted successfully'**
  String get documentDeleted;

  /// Generic error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get networkError;

  /// Permission denied error message
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please grant required permissions'**
  String get permissionDenied;

  /// File not found error message
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileNotFound;

  /// Unsupported file type error message
  ///
  /// In en, this message translates to:
  /// **'Unsupported file type'**
  String get unsupportedFileType;

  /// File too large error message
  ///
  /// In en, this message translates to:
  /// **'File size exceeds maximum limit'**
  String get fileTooLarge;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Help button text
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// About button text
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
