import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/document_providers.dart';

class DocumentUploadWidget extends ConsumerStatefulWidget {
  final VoidCallback? onUploadComplete;
  final bool showAsDialog;

  const DocumentUploadWidget({
    super.key,
    this.onUploadComplete,
    this.showAsDialog = false,
  });

  @override
  ConsumerState<DocumentUploadWidget> createState() =>
      _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends ConsumerState<DocumentUploadWidget> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedFilePath;
  String? _selectedFileName;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final uploadData = ref.watch(uploadProvider);

    if (widget.showAsDialog) {
      return _buildDialog(context, localizations, uploadData);
    }

    return _buildContent(context, localizations, uploadData);
  }

  Widget _buildDialog(
    BuildContext context,
    AppLocalizations localizations,
    UploadData uploadData,
  ) {
    return AlertDialog(
      title: Text(localizations.uploadDocument),
      content: SizedBox(
        width: double.maxFinite,
        child: _buildContent(context, localizations, uploadData),
      ),
      actions:
          uploadData.state == UploadState.uploading ||
              uploadData.state == UploadState.processing
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed: _canUpload() ? _handleUpload : null,
                child: Text(localizations.uploadDocument),
              ),
            ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations localizations,
    UploadData uploadData,
  ) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File selection
            _buildFileSelector(localizations),

            const SizedBox(height: 16),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Document Title *',
                border: const OutlineInputBorder(),
                hintText: 'Enter a descriptive title',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
              enabled:
                  uploadData.state != UploadState.uploading &&
                  uploadData.state != UploadState.processing,
            ),

            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Add a description for this document',
              ),
              maxLines: 3,
              enabled:
                  uploadData.state != UploadState.uploading &&
                  uploadData.state != UploadState.processing,
            ),

            const SizedBox(height: 16),

            // Tags field
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Enter tags separated by commas',
              ),
              enabled:
                  uploadData.state != UploadState.uploading &&
                  uploadData.state != UploadState.processing,
            ),

            const SizedBox(height: 16),

            // Upload progress
            if (uploadData.state == UploadState.uploading ||
                uploadData.state == UploadState.processing) ...[
              _buildUploadProgress(uploadData),
              const SizedBox(height: 16),
            ],

            // Error message
            if (uploadData.state == UploadState.error) ...[
              _buildErrorMessage(uploadData.errorMessage ?? 'Upload failed'),
              const SizedBox(height: 16),
            ],

            // Success message
            if (uploadData.state == UploadState.completed) ...[
              _buildSuccessMessage(localizations.documentUploaded),
              const SizedBox(height: 16),
            ],

            // Upload button (if not in dialog)
            if (!widget.showAsDialog) ...[
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: Text(localizations.uploadDocument),
                  onPressed: _canUpload() ? _handleUpload : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelector(AppLocalizations localizations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select PDF File *',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            if (_selectedFilePath == null) ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _pickFile,
                      child: const Text('Choose PDF File'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Maximum file size: ${AppConstants.maxFileSizeInMB}MB',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFileName ?? 'Unknown file',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          _getFileSize(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearFile,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProgress(UploadData uploadData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              uploadData.statusMessage ?? 'Uploading...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: uploadData.progress,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 4),
            Text(
              '${(uploadData.progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: () => ref.read(uploadProvider.notifier).clearError(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessMessage(String message) {
    return Card(
      color: Colors.green.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.green.shade800),
              ),
            ),
            TextButton(
              onPressed: _resetForm,
              child: const Text('Upload Another'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.path != null) {
          // Check file size
          final fileSize = File(file.path!).lengthSync();
          if (fileSize > AppConstants.maxFileSizeInMB * 1024 * 1024) {
            _showError(
              'File size exceeds ${AppConstants.maxFileSizeInMB}MB limit',
            );
            return;
          }

          setState(() {
            _selectedFilePath = file.path;
            _selectedFileName = file.name;
          });

          // Auto-fill title if empty
          if (_titleController.text.isEmpty) {
            final nameWithoutExtension = file.name.replaceAll('.pdf', '');
            _titleController.text = nameWithoutExtension;
          }
        }
      }
    } catch (e) {
      _showError('Failed to pick file: $e');
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFilePath = null;
      _selectedFileName = null;
    });
  }

  String _getFileSize() {
    if (_selectedFilePath == null) return '';

    try {
      final file = File(_selectedFilePath!);
      final bytes = file.lengthSync();
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown size';
    }
  }

  bool _canUpload() {
    return _selectedFilePath != null &&
        _titleController.text.trim().isNotEmpty &&
        ref.read(uploadProvider).state != UploadState.uploading &&
        ref.read(uploadProvider).state != UploadState.processing;
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate() || !_canUpload()) return;

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    await ref
        .read(uploadProvider.notifier)
        .uploadDocument(
          filePath: _selectedFilePath!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          tags: tags.isEmpty ? null : tags,
        );

    // Refresh document list after successful upload
    final uploadState = ref.read(uploadProvider).state;
    if (uploadState == UploadState.completed) {
      ref.read(documentListProvider.notifier).refresh();
      widget.onUploadComplete?.call();

      if (widget.showAsDialog && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _tagsController.clear();
    _clearFile();
    ref.read(uploadProvider.notifier).reset();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
