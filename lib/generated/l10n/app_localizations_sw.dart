// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'VIA - Msaidizi wa Sauti';

  @override
  String get welcome => 'Karibu VIA';

  @override
  String get documents => 'Hati';

  @override
  String get settings => 'Mipangilio';

  @override
  String get uploadDocument => 'Pakia Hati';

  @override
  String get deleteDocument => 'Futa Hati';

  @override
  String get openDocument => 'Fungua Hati';

  @override
  String get readDocument => 'Soma Hati';

  @override
  String get stopReading => 'Acha Kusoma';

  @override
  String get pauseReading => 'Simamisha Kusoma';

  @override
  String get resumeReading => 'Endelea Kusoma';

  @override
  String get nextPage => 'Ukurasa Unaofuata';

  @override
  String get previousPage => 'Ukurasa Uliotangulia';

  @override
  String get goToPage => 'Nenda Ukurasa';

  @override
  String pageNumber(int number) {
    return 'Ukurasa $number';
  }

  @override
  String totalPages(int total) {
    return 'Kurasa $total';
  }

  @override
  String get language => 'Lugha';

  @override
  String get english => 'Kiingereza';

  @override
  String get swahili => 'Kiswahili';

  @override
  String get speechSettings => 'Mipangilio ya Sauti';

  @override
  String get speechRate => 'Kasi ya Kusema';

  @override
  String get pitch => 'Mlolongo wa Sauti';

  @override
  String get volume => 'Kiwango cha Sauti';

  @override
  String get accessibilitySettings => 'Mipangilio ya Ufikaji';

  @override
  String get highContrastMode => 'Hali ya Utofauti Mkubwa';

  @override
  String get textSize => 'Ukubwa wa Maandishi';

  @override
  String get voiceFeedback => 'Majibu ya Sauti';

  @override
  String get hapticFeedback => 'Majibu ya Kugusa';

  @override
  String get voiceCommands => 'Amri za Sauti';

  @override
  String get startListening => 'Anza Kusikiliza';

  @override
  String get stopListening => 'Acha Kusikiliza';

  @override
  String get listening => 'Ninasikiliza...';

  @override
  String get speakCommand => 'Sema amri';

  @override
  String get commandNotRecognized => 'Amri haijatambuliwa';

  @override
  String get noDocuments => 'Hakuna hati zilizopatikana';

  @override
  String get uploadingDocument => 'Ninapakia hati...';

  @override
  String get documentUploaded => 'Hati imepakiwa kwa mafanikio';

  @override
  String get documentDeleted => 'Hati imefutwa kwa mafanikio';

  @override
  String get error => 'Hitilafu';

  @override
  String get networkError => 'Tafadhali angalia muunganisho wako wa mtandao';

  @override
  String get permissionDenied =>
      'Ruhusa imekataliwa. Tafadhali toa ruhusa zinazohitajika';

  @override
  String get fileNotFound => 'Faili halijapatikana';

  @override
  String get unsupportedFileType => 'Aina ya faili haihamiliwi';

  @override
  String get fileTooLarge => 'Ukubwa wa faili umezidi kikomo cha juu';

  @override
  String get cancel => 'Ghairi';

  @override
  String get ok => 'Sawa';

  @override
  String get save => 'Hifadhi';

  @override
  String get help => 'Msaada';

  @override
  String get about => 'Kuhusu';
}
