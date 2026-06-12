import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/document_entity.dart';
import '../../presentation/controllers/document_controller.dart';
import '../../providers/document_providers.dart';

class DocumentListScreen extends ConsumerStatefulWidget {
  const DocumentListScreen({super.key});

  @override
  ConsumerState<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends ConsumerState<DocumentListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(documentControllerProvider.notifier).loadDocuments();
    });
  }

  void _confirmDelete(DocumentEntity document) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text(
          'Are you sure you want to delete "${document.filename}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref
                  .read(documentControllerProvider.notifier)
                  .deleteDocument(document.id);
              ctx.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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

  Color _getStatusColor(String? status, ColorScheme colorScheme) {
    switch (status?.toLowerCase()) {
      case 'ready':
        return colorScheme.primary;
      case 'processing':
        return colorScheme.tertiary;
      case 'error':
        return colorScheme.error;
      default:
        return colorScheme.outline;
    }
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.month}/${dt.day}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen<DocumentState>(documentControllerProvider, (prev, next) {
      if (next.successMessage != null && prev?.successMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Future.microtask(() {
          ref.read(documentControllerProvider.notifier).clearSuccess();
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        centerTitle: true,
      ),
      body: _buildContent(state, colorScheme),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/documents/upload'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(DocumentState state, ColorScheme colorScheme) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: colorScheme.onSurfaceVariant.withAlpha(100),
            ),
            const SizedBox(height: DesignTokens.space16),
            Text(
              'No documents uploaded yet.\nTap + to upload a document.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(documentControllerProvider.notifier).loadDocuments();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(DesignTokens.space16),
        itemCount: state.documents.length,
        itemBuilder: (context, index) {
          final document = state.documents[index];
          return Dismissible(
            key: ValueKey(document.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: DesignTokens.space16),
              color: colorScheme.error,
              child: Icon(Icons.delete, color: colorScheme.onError),
            ),
            confirmDismiss: (_) async {
              _confirmDelete(document);
              return false;
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: DesignTokens.space8),
              child: ListTile(
                leading: Icon(
                  _getFileIcon(document.filename),
                  color: colorScheme.primary,
                  size: 32,
                ),
                title: Text(
                  document.filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Row(
                  children: [
                    if (document.sizeBytes != null) ...[
                      Text(_formatFileSize(document.sizeBytes)),
                      const Text(' · '),
                    ],
                    if (document.createdAt != null)
                      Text(_formatDate(document.createdAt)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (document.status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.space8,
                          vertical: DesignTokens.space2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            document.status,
                            colorScheme,
                          ).withAlpha(30),
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusFull,
                          ),
                        ),
                        child: Text(
                          document.status!,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(
                              document.status,
                              colorScheme,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: DesignTokens.space4),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                      onPressed: () => _confirmDelete(document),
                    ),
                  ],
                ),
                onTap: () {
                  // Show document details
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
