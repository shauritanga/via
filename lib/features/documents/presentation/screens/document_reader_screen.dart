import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../voice_commands/presentation/providers/document_reader_provider.dart';
import '../../../voice_commands/presentation/widgets/reading_controls.dart';
import '../../../voice_commands/presentation/widgets/tts_settings_widget.dart';
import '../../../voice_commands/domain/usecases/read_document_content.dart';
import '../providers/document_providers.dart';

class DocumentReaderScreen extends ConsumerStatefulWidget {
  final String documentId;

  const DocumentReaderScreen({super.key, required this.documentId});

  @override
  ConsumerState<DocumentReaderScreen> createState() =>
      _DocumentReaderScreenState();
}

class _DocumentReaderScreenState extends ConsumerState<DocumentReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showControls = true;

  @override
  void initState() {
    super.initState();

    // Load the document when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocument();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDocument() async {
    // Get the document by ID and load it in the reader
    final documentListData = ref.read(documentListProvider);
    final document = documentListData.documents
        .where((doc) => doc.id == widget.documentId)
        .firstOrNull;

    if (document != null) {
      await ref.read(documentReaderProvider.notifier).loadDocument(document);
    }
  }

  @override
  Widget build(BuildContext context) {
    final readerState = ref.watch(documentReaderProvider);
    final documentContent = ref.watch(
      documentContentProvider(widget.documentId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(readerState.currentDocument?.title ?? 'Document'),
        actions: [
          IconButton(
            icon: Icon(_showControls ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            tooltip: _showControls ? 'Hide controls' : 'Show controls',
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const TTSSettingsWidget(showAsDialog: true),
            ),
            tooltip: 'TTS Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Reading controls
          if (_showControls) ...[
            const ReadingControls(showAdvancedControls: false),
            const Divider(height: 1),
          ],

          // Document content
          Expanded(
            child: documentContent.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorView(error.toString()),
              data: (content) => _buildDocumentView(content, readerState),
            ),
          ),

          // Bottom controls (compact)
          if (_showControls) ...[
            const Divider(height: 1),
            const ReadingControls(showAdvancedControls: false, isCompact: true),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load document',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadDocument, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildDocumentView(dynamic content, DocumentReaderData readerState) {
    if (content.pages.isEmpty) {
      return const Center(child: Text('No content available'));
    }

    final currentPage = readerState.currentPage;
    final pageContent = content.pages[currentPage - 1];

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Page $currentPage of ${content.pages.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Page content
          _buildPageContent(pageContent),

          // Reading progress indicator
          if (readerState.state == DocumentReaderState.reading) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.volume_up,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reading in progress...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: readerState.readingProgress,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPageContent(dynamic pageContent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page text
        SelectableText(
          pageContent.text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
        ),

        // Sections (if any)
        if (pageContent.sections.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Sections on this page:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...pageContent.sections.map((section) => _buildSectionCard(section)),
        ],
      ],
    );
  }

  Widget _buildSectionCard(dynamic section) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(_getSectionIcon(section.type)),
        title: Text(section.title),
        subtitle: Text(
          section.content.length > 100
              ? '${section.content.substring(0, 100)}...'
              : section.content,
        ),
        onTap: () {
          // Start reading this specific section
          ref
              .read(documentReaderProvider.notifier)
              .startReading(
                mode: ReadingMode.specificSection,
                sectionName: section.title,
              );
        },
      ),
    );
  }

  IconData _getSectionIcon(dynamic sectionType) {
    // This would map section types to appropriate icons
    switch (sectionType.toString()) {
      case 'SectionType.heading':
        return Icons.title;
      case 'SectionType.list':
        return Icons.list;
      case 'SectionType.table':
        return Icons.table_chart;
      case 'SectionType.paragraph':
      default:
        return Icons.text_fields;
    }
  }
}
