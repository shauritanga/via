import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../providers/document_reader_provider.dart';
import '../../domain/usecases/read_document_content.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class ReadingControls extends ConsumerWidget {
  final bool showAdvancedControls;
  final bool isCompact;

  const ReadingControls({
    super.key,
    this.showAdvancedControls = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readerState = ref.watch(documentReaderProvider);
    final localizations = AppLocalizations.of(context);

    if (isCompact) {
      return _buildCompactControls(context, ref, readerState, localizations);
    }

    return _buildFullControls(context, ref, readerState, localizations);
  }

  Widget _buildCompactControls(
    BuildContext context,
    WidgetRef ref,
    DocumentReaderData readerState,
    AppLocalizations localizations,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          context,
          icon: Icons.skip_previous,
          label: localizations.previousPage,
          onPressed: readerState.currentPage > 1
              ? () => ref.read(documentReaderProvider.notifier).previousPage()
              : null,
        ),
        _buildPlayPauseButton(context, ref, readerState, localizations),
        _buildControlButton(
          context,
          icon: Icons.skip_next,
          label: localizations.nextPage,
          onPressed:
              readerState.currentPage <
                  (readerState.documentContent?.pages.length ?? 0)
              ? () => ref.read(documentReaderProvider.notifier).nextPage()
              : null,
        ),
      ],
    );
  }

  Widget _buildFullControls(
    BuildContext context,
    WidgetRef ref,
    DocumentReaderData readerState,
    AppLocalizations localizations,
  ) {
    return Column(
      children: [
        // Progress indicator
        if (readerState.state == DocumentReaderState.reading) ...[
          LinearProgressIndicator(
            value: readerState.readingProgress,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Main controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              context,
              icon: Icons.skip_previous,
              label: localizations.previousPage,
              onPressed: readerState.currentPage > 1
                  ? () =>
                        ref.read(documentReaderProvider.notifier).previousPage()
                  : null,
            ),
            _buildPlayPauseButton(context, ref, readerState, localizations),
            _buildControlButton(
              context,
              icon: Icons.skip_next,
              label: localizations.nextPage,
              onPressed:
                  readerState.currentPage <
                      (readerState.documentContent?.pages.length ?? 0)
                  ? () => ref.read(documentReaderProvider.notifier).nextPage()
                  : null,
            ),
            _buildControlButton(
              context,
              icon: Icons.stop,
              label: localizations.stopReading,
              onPressed:
                  readerState.state == DocumentReaderState.reading ||
                      readerState.state == DocumentReaderState.paused
                  ? () =>
                        ref.read(documentReaderProvider.notifier).stopReading()
                  : null,
            ),
          ],
        ),

        if (showAdvancedControls) ...[
          const SizedBox(height: 16),
          _buildAdvancedControls(context, ref, readerState, localizations),
        ],

        // Page indicator
        if (readerState.documentContent != null) ...[
          const SizedBox(height: 8),
          Text(
            '${localizations.pageNumber(readerState.currentPage)} / ${localizations.totalPages(readerState.documentContent!.pages.length)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildPlayPauseButton(
    BuildContext context,
    WidgetRef ref,
    DocumentReaderData readerState,
    AppLocalizations localizations,
  ) {
    IconData icon;
    String label;
    VoidCallback? onPressed;

    switch (readerState.state) {
      case DocumentReaderState.idle:
        icon = Icons.play_arrow;
        label = localizations.readDocument;
        onPressed = readerState.documentContent != null
            ? () => ref.read(documentReaderProvider.notifier).startReading()
            : null;
        break;
      case DocumentReaderState.reading:
        icon = Icons.pause;
        label = localizations.pauseReading;
        onPressed = () =>
            ref.read(documentReaderProvider.notifier).pauseReading();
        break;
      case DocumentReaderState.paused:
        icon = Icons.play_arrow;
        label = localizations.resumeReading;
        onPressed = () =>
            ref.read(documentReaderProvider.notifier).resumeReading();
        break;
      case DocumentReaderState.loading:
        icon = Icons.hourglass_empty;
        label = 'Loading...';
        onPressed = null;
        break;
      case DocumentReaderState.error:
        icon = Icons.error;
        label = localizations.error;
        onPressed = () =>
            ref.read(documentReaderProvider.notifier).clearError();
        break;
    }

    return _buildControlButton(
      context,
      icon: icon,
      label: label,
      onPressed: onPressed,
      isPrimary: true,
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    return Semantics(
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: onPressed,
            iconSize: isPrimary ? 32 : 24,
            style: isPrimary
                ? IconButton.styleFrom(
                    backgroundColor: onPressed != null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor: onPressed != null
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  )
                : null,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedControls(
    BuildContext context,
    WidgetRef ref,
    DocumentReaderData readerState,
    AppLocalizations localizations,
  ) {
    return Column(
      children: [
        // Reading mode selector
        Row(
          children: [
            Text(
              'Reading Mode:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<ReadingMode>(
                value: readerState.readingMode,
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: ReadingMode.fullDocument,
                    child: Text('Full Document'),
                  ),
                  DropdownMenuItem(
                    value: ReadingMode.currentPage,
                    child: Text('Current Page'),
                  ),
                  DropdownMenuItem(
                    value: ReadingMode.specificSection,
                    child: Text('Specific Section'),
                  ),
                  DropdownMenuItem(
                    value: ReadingMode.pageRange,
                    child: Text('Page Range'),
                  ),
                ],
                onChanged: (ReadingMode? mode) {
                  if (mode != null) {
                    ref
                        .read(documentReaderProvider.notifier)
                        .setReadingMode(mode);
                  }
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Quick navigation
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.first_page),
                label: Text('First Page'),
                onPressed: readerState.currentPage > 1
                    ? () =>
                          ref.read(documentReaderProvider.notifier).goToPage(1)
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.last_page),
                label: Text('Last Page'),
                onPressed:
                    readerState.documentContent != null &&
                        readerState.currentPage <
                            readerState.documentContent!.pages.length
                    ? () => ref
                          .read(documentReaderProvider.notifier)
                          .goToPage(readerState.documentContent!.pages.length)
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Reading preferences dialog
class ReadingPreferencesDialog extends ConsumerStatefulWidget {
  const ReadingPreferencesDialog({super.key});

  @override
  ConsumerState<ReadingPreferencesDialog> createState() =>
      _ReadingPreferencesDialogState();
}

class _ReadingPreferencesDialogState
    extends ConsumerState<ReadingPreferencesDialog> {
  late ReadingPreferences _preferences;

  @override
  void initState() {
    super.initState();
    final readerState = ref.read(documentReaderProvider);
    _preferences =
        readerState.readingPreferences ??
        ReadingPreferences(language: ref.read(currentLanguageProvider));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Text('Reading Preferences'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Add pauses for punctuation'),
              value: _preferences.addPausesForPunctuation,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    addPausesForPunctuation: value,
                  );
                });
              },
            ),
            SwitchListTile(
              title: Text('Skip page numbers'),
              value: _preferences.skipPageNumbers,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(skipPageNumbers: value);
                });
              },
            ),
            SwitchListTile(
              title: Text('Skip footnotes'),
              value: _preferences.skipFootnotes,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(skipFootnotes: value);
                });
              },
            ),
            SwitchListTile(
              title: Text('Spell out abbreviations'),
              value: _preferences.spellOutAbbreviations,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    spellOutAbbreviations: value,
                  );
                });
              },
            ),
            SwitchListTile(
              title: Text('Announce page numbers'),
              value: _preferences.announcePageNumbers,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    announcePageNumbers: value,
                  );
                });
              },
            ),
            SwitchListTile(
              title: Text('Announce section titles'),
              value: _preferences.announceSectionTitles,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    announceSectionTitles: value,
                  );
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        TextButton(
          onPressed: () {
            ref
                .read(documentReaderProvider.notifier)
                .updateReadingPreferences(_preferences);
            Navigator.of(context).pop();
          },
          child: Text(localizations.save),
        ),
      ],
    );
  }
}
