import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/entities/document.dart';
import '../providers/document_providers.dart';
import 'document_upload_widget.dart';

class DocumentListWidget extends ConsumerWidget {
  final Function(Document)? onDocumentSelected;
  final bool showUploadButton;
  final bool showSearchBar;

  const DocumentListWidget({
    super.key,
    this.onDocumentSelected,
    this.showUploadButton = true,
    this.showSearchBar = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentListData = ref.watch(documentListProvider);
    final filteredDocuments = ref.watch(filteredDocumentsProvider);
    final localizations = AppLocalizations.of(context);

    return Column(
      children: [
        // Search bar
        if (showSearchBar) ...[
          _buildSearchBar(context, ref, localizations),
          const SizedBox(height: 8),
        ],

        // Upload button
        if (showUploadButton) ...[
          _buildUploadButton(context, localizations),
          const SizedBox(height: 8),
        ],

        // Document list
        Expanded(
          child: _buildDocumentList(
            context,
            ref,
            documentListData,
            filteredDocuments,
            localizations,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations localizations,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search documents...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        onChanged: (value) {
          ref.read(documentSearchProvider.notifier).state = value;
        },
      ),
    );
  }

  Widget _buildUploadButton(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: Text(localizations.uploadDocument),
          onPressed: () => showDialog(
            context: context,
            builder: (context) =>
                const DocumentUploadWidget(showAsDialog: true),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentList(
    BuildContext context,
    WidgetRef ref,
    DocumentListData documentListData,
    List<Document> filteredDocuments,
    AppLocalizations localizations,
  ) {
    switch (documentListData.state) {
      case DocumentListState.loading:
        return const Center(child: CircularProgressIndicator());

      case DocumentListState.error:
        return _buildErrorState(context, ref, documentListData, localizations);

      case DocumentListState.empty:
        return _buildEmptyState(context, localizations);

      case DocumentListState.loaded:
        if (filteredDocuments.isEmpty) {
          return _buildNoSearchResults(context, localizations);
        }
        return _buildLoadedState(
          context,
          ref,
          filteredDocuments,
          localizations,
        );
    }
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    DocumentListData documentListData,
    AppLocalizations localizations,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.error,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            documentListData.errorMessage ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(documentListProvider.notifier).clearError();
              ref.read(documentListProvider.notifier).refresh();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.noDocuments,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your first PDF document to get started',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: Text(localizations.uploadDocument),
            onPressed: () => showDialog(
              context: context,
              builder: (context) =>
                  const DocumentUploadWidget(showAsDialog: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No documents found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    WidgetRef ref,
    List<Document> documents,
    AppLocalizations localizations,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(documentListProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final document = documents[index];
          return DocumentListItem(
            document: document,
            onTap: () => onDocumentSelected?.call(document),
            onDelete: () =>
                _showDeleteConfirmation(context, ref, document, localizations),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Document document,
    AppLocalizations localizations,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteDocument),
        content: Text('Are you sure you want to delete "${document.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(documentListProvider.notifier)
                  .deleteDocument(document.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(localizations.deleteDocument),
          ),
        ],
      ),
    );
  }
}

class DocumentListItem extends StatelessWidget {
  final Document document;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DocumentListItem({
    super.key,
    required this.document,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.picture_as_pdf,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          document.title,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (document.description.isNotEmpty) ...[
              Text(
                document.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Icon(
                  Icons.pages,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  '${document.totalPages} pages',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.language,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  document.language.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Uploaded ${_formatDate(document.uploadedAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete':
                onDelete?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
