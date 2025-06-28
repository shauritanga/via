import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:via/core/usecases/usecase.dart';
import '../../features/settings/domain/usecases/get_language_preference.dart';
import '../../features/settings/domain/usecases/set_language_preference.dart';
import '../constants/app_constants.dart';
import 'dependency_injection.dart';

class LocalizationService {
  static const List<Locale> supportedLocales = [
    Locale(AppConstants.englishLocale),
    Locale(AppConstants.swahiliLocale),
  ];

  static Locale getLocaleFromLanguageCode(String languageCode) {
    switch (languageCode) {
      case AppConstants.englishLocale:
        return const Locale(AppConstants.englishLocale);
      case AppConstants.swahiliLocale:
        return const Locale(AppConstants.swahiliLocale);
      default:
        return const Locale(AppConstants.englishLocale);
    }
  }

  static String getLanguageNameFromCode(String languageCode) {
    switch (languageCode) {
      case AppConstants.englishLocale:
        return 'English';
      case AppConstants.swahiliLocale:
        return 'Kiswahili';
      default:
        return 'English';
    }
  }

  static String getLanguageNameInSwahili(String languageCode) {
    switch (languageCode) {
      case AppConstants.englishLocale:
        return 'Kiingereza';
      case AppConstants.swahiliLocale:
        return 'Kiswahili';
      default:
        return 'Kiingereza';
    }
  }

  static bool isRTL(String languageCode) {
    // Neither English nor Swahili are RTL languages
    return false;
  }
}

// Riverpod provider for current locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale(AppConstants.englishLocale)) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final getLanguagePreference = sl<GetLanguagePreference>();
      final result = await getLanguagePreference(NoParams());
      
      result.fold(
        (failure) {
          // Use default language if failed to load
          state = const Locale(AppConstants.englishLocale);
        },
        (languageCode) {
          state = LocalizationService.getLocaleFromLanguageCode(languageCode);
        },
      );
    } catch (e) {
      // Use default language if error occurs
      state = const Locale(AppConstants.englishLocale);
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    try {
      final setLanguagePreference = sl<SetLanguagePreference>();
      final result = await setLanguagePreference(
        SetLanguagePreferenceParams(language: languageCode),
      );
      
      result.fold(
        (failure) {
          // Handle error - could show a snackbar or log
          print('Failed to save language preference: $failure');
        },
        (_) {
          // Successfully saved, update the state
          state = LocalizationService.getLocaleFromLanguageCode(languageCode);
        },
      );
    } catch (e) {
      print('Error changing language: $e');
    }
  }

  String get currentLanguageCode => state.languageCode;
  
  bool get isEnglish => state.languageCode == AppConstants.englishLocale;
  bool get isSwahili => state.languageCode == AppConstants.swahiliLocale;
}
