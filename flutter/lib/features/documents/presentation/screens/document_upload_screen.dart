import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../providers/document_providers.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  ConsumerState<DocumentUploadScreen> createState() =>
      _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  PlatformFile? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null || _selectedFile!.path == null) return;

    await ref.read(documentControllerProvider.notifier).uploadDocument(
          _selectedFile!.path!,
          _selectedFile!.name,
        );

    if (mounted && context.mounted) {
      context.pop();
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.error != null)
              Container(
                padding: const EdgeInsets.all(DesignTokens.space12),
                margin: const EdgeInsets.only(bottom: DesignTokens.space16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.error!,
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onErrorContainer,
                      ),
                      onPressed: () => ref
                          .read(documentControllerProvider.notifier)
                          .clearError(),
                    ),
                  ],
                ),
              ),
            InkWell(
              onTap: state.isUploading ? null : _pickFile,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedFile != null
                        ? colorScheme.primary
                        : colorScheme.outline,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  color: _selectedFile != null
                      ? colorScheme.primaryContainer.withAlpha(50)
                      : colorScheme.surfaceContainerLow,
                ),
                child: _selectedFile != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getFileIcon(_selectedFile!.name),
                            size: 48,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: DesignTokens.space12),
                          Text(
                            _selectedFile!.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: DesignTokens.space4),
                          Text(
                            _formatSize(_selectedFile!.size),
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.space8),
                          TextButton.icon(
                            onPressed: _pickFile,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Change file'),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 48,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: DesignTokens.space12),
                          Text(
                            'Tap to select a file',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.space4),
                          Text(
                            'PDF, DOC, TXT, images...',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant
                                  .withAlpha(150),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed:
                    _selectedFile != null && !state.isUploading
                        ? _uploadFile
                        : null,
                icon: state.isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload),
                label:
                    Text(state.isUploading ? 'Uploading...' : 'Upload Document'),
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
          ],
        ),
      ),
    );
  }
}
