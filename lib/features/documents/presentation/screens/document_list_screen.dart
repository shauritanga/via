import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../providers/document_providers.dart';
import '../widgets/document_list_widget.dart';
import '../widgets/document_upload_widget.dart';
import '../../../voice_commands/presentation/widgets/voice_status_indicator.dart';

class DocumentListScreen extends ConsumerWidget {
  const DocumentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final documentStats = ref.watch(documentStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.documents),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => showDialog(
              context: context,
              builder: (context) =>
                  const DocumentUploadWidget(showAsDialog: true),
            ),
            tooltip: localizations.uploadDocument,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(documentListProvider.notifier).refresh(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Statistics card
              if (documentStats['totalDocuments'] > 0) ...[
                _buildStatsCard(context, documentStats, localizations),
                const SizedBox(height: 8),
              ],

              // Document list
              Expanded(
                child: DocumentListWidget(
                  onDocumentSelected: (document) {
                    // Set the selected document and navigate to reader
                    ref.read(selectedDocumentProvider.notifier).state =
                        document;
                    context.go('${AppRoutes.documents}/reader/${document.id}');
                  },
                  showUploadButton: documentStats['totalDocuments'] == 0,
                  showSearchBar: documentStats['totalDocuments'] > 0,
                ),
              ),
            ],
          ),
          // Voice status indicator overlay
          const VoiceStatusIndicator(showAsOverlay: true),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    Map<String, dynamic> stats,
    AppLocalizations localizations,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                Icons.description,
                '${stats['totalDocuments']}',
                'Documents',
              ),
              _buildStatItem(
                context,
                Icons.pages,
                '${stats['totalPages']}',
                'Total Pages',
              ),
              _buildStatItem(
                context,
                Icons.language,
                '${stats['languages'].length}',
                'Languages',
              ),
              _buildStatItem(
                context,
                Icons.schedule,
                '${stats['recentUploads']}',
                'Recent',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
