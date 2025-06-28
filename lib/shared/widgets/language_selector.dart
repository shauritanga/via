import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/localization_service.dart';
import '../../core/constants/app_constants.dart';

class LanguageSelector extends ConsumerWidget {
  final bool showAsDialog;
  final VoidCallback? onLanguageChanged;

  const LanguageSelector({
    super.key,
    this.showAsDialog = false,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final localizations = AppLocalizations.of(context)!;

    if (showAsDialog) {
      return _buildDialogContent(context, ref, currentLocale, localizations);
    }

    return _buildDropdownContent(context, ref, currentLocale, localizations);
  }

  Widget _buildDropdownContent(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
    AppLocalizations localizations,
  ) {
    return DropdownButton<String>(
      value: currentLocale.languageCode,
      items: [
        DropdownMenuItem(
          value: AppConstants.englishLocale,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language),
              const SizedBox(width: 8),
              Text(localizations.english),
            ],
          ),
        ),
        DropdownMenuItem(
          value: AppConstants.swahiliLocale,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language),
              const SizedBox(width: 8),
              Text(localizations.swahili),
            ],
          ),
        ),
      ],
      onChanged: (String? newLanguage) {
        if (newLanguage != null) {
          _changeLanguage(ref, newLanguage);
        }
      },
      underline: Container(),
      icon: const Icon(Icons.arrow_drop_down),
    );
  }

  Widget _buildDialogContent(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
    AppLocalizations localizations,
  ) {
    return AlertDialog(
      title: Text(localizations.language),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(localizations.english),
            trailing: currentLocale.languageCode == AppConstants.englishLocale
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              _changeLanguage(ref, AppConstants.englishLocale);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(localizations.swahili),
            trailing: currentLocale.languageCode == AppConstants.swahiliLocale
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              _changeLanguage(ref, AppConstants.swahiliLocale);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
      ],
    );
  }

  void _changeLanguage(WidgetRef ref, String languageCode) {
    ref.read(localeProvider.notifier).changeLanguage(languageCode);
    onLanguageChanged?.call();
  }

  static void showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSelector(showAsDialog: true),
    );
  }
}

// Voice-activated language selector
class VoiceLanguageSelector extends ConsumerWidget {
  const VoiceLanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final localizations = AppLocalizations.of(context)!;

    return Semantics(
      label: '${localizations.language}: ${_getLanguageName(currentLocale.languageCode, localizations)}',
      hint: 'Double tap to change language',
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.language, size: 32),
          title: Text(
            localizations.language,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          subtitle: Text(
            _getLanguageName(currentLocale.languageCode, localizations),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => LanguageSelector.showLanguageDialog(context),
        ),
      ),
    );
  }

  String _getLanguageName(String languageCode, AppLocalizations localizations) {
    switch (languageCode) {
      case AppConstants.englishLocale:
        return localizations.english;
      case AppConstants.swahiliLocale:
        return localizations.swahili;
      default:
        return localizations.english;
    }
  }
}
