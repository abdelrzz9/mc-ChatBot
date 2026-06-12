import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/conversation.dart';
import '../../presentation/controllers/conversation_list_controller.dart';
import '../../providers/chat_providers.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newChatController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(conversationListControllerProvider.notifier).loadConversations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _newChatController.dispose();
    super.dispose();
  }

  void _showNewChatDialog() {
    _newChatController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Chat'),
        content: TextField(
          controller: _newChatController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter conversation title...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _createConversation(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _createConversation(ctx),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createConversation(BuildContext dialogContext) {
    final title = _newChatController.text.trim();
    if (title.isEmpty) return;
    ref.read(conversationListControllerProvider.notifier).createConversation(
          title,
        );
    dialogContext.pop();
  }

  void _confirmDelete(String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: Text('Are you sure you want to delete "$title"?'),
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
                  .read(conversationListControllerProvider.notifier)
                  .deleteConversation(id);
              ctx.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationListControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final filtered = state.conversations.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(DesignTokens.space16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusFull),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space16,
                  vertical: DesignTokens.space12,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space16,
                vertical: DesignTokens.space8,
              ),
              child: Text(
                state.error!,
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          Expanded(
            child: _buildContent(state, filtered, colorScheme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(
    ConversationListState state,
    List<Conversation> filtered,
    ColorScheme colorScheme,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: colorScheme.onSurfaceVariant.withAlpha(100),
            ),
            const SizedBox(height: DesignTokens.space16),
            Text(
              state.conversations.isEmpty
                  ? 'No conversations yet.\nTap + to start a new chat.'
                  : 'No conversations match your search.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(conversationListControllerProvider.notifier)
            .loadConversations();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final conversation = filtered[index];
          return Dismissible(
            key: ValueKey(conversation.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: DesignTokens.space16),
              color: colorScheme.error,
              child: Icon(Icons.delete, color: colorScheme.onError),
            ),
            onDismissed: (_) {
              ref
                  .read(conversationListControllerProvider.notifier)
                  .deleteConversation(conversation.id);
            },
            confirmDismiss: (_) async {
              _confirmDelete(conversation.id, conversation.title);
              return false;
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: DesignTokens.space8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.chat,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  conversation.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: conversation.updatedAt != null
                    ? Text(
                        _formatDate(conversation.updatedAt!),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : null,
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: colorScheme.error,
                  ),
                  onPressed: () =>
                      _confirmDelete(conversation.id, conversation.title),
                ),
                onTap: () => context.push('/chat/${conversation.id}'),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.month}/${dt.day}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
