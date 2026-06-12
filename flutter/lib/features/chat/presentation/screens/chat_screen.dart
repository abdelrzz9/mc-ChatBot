import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../presentation/controllers/chat_controller.dart';
import '../../providers/chat_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isNearBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      ref
          .read(chatControllerProvider.notifier)
          .selectConversation(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final nearBottom = (maxScroll - currentScroll) < 100;
    if (nearBottom != _isNearBottom) {
      setState(() => _isNearBottom = nearBottom);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    ref.read(chatControllerProvider.notifier).sendMessage(text);
    Future.microtask(_scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen<ChatState>(chatControllerProvider, (prev, next) {
      if (next.messages.length != (prev?.messages.length ?? 0) ||
          next.currentResponse != prev?.currentResponse) {
        if (_isNearBottom) {
          Future.microtask(_scrollToBottom);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.currentConversation?.title ?? 'Chat',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (state.isStreaming)
            IconButton(
              onPressed: () =>
                  ref.read(chatControllerProvider.notifier).cancelStreaming(),
              icon: const Icon(Icons.stop),
              tooltip: 'Stop generating',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(state, colorScheme)),
          if (state.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignTokens.space8),
              color: colorScheme.errorContainer,
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
                    onPressed: () =>
                        ref.read(chatControllerProvider.notifier).clearError(),
                  ),
                ],
              ),
            ),
          _buildInputBar(colorScheme, state.isStreaming),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatState state, ColorScheme colorScheme) {
    if (state.messages.isEmpty && !state.isStreaming && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.messages.isEmpty && !state.isStreaming) {
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
              'Start a conversation',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(DesignTokens.space16),
      itemCount: state.messages.length + (state.isStreaming ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.messages.length && state.isStreaming) {
          return _MessageBubble(
            message: state.currentResponse ?? '',
            isUser: false,
            isStreaming: true,
          );
        }
        final message = state.messages[index];
        return _MessageBubble(
          message: message.content,
          isUser: message.role == 'user',
        );
      },
    );
  }

  Widget _buildInputBar(ColorScheme colorScheme, bool isStreaming) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusFull),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.space16,
                    vertical: DesignTokens.space12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: DesignTokens.space8),
            IconButton.filled(
              onPressed: isStreaming ? null : _sendMessage,
              icon: Icon(isStreaming ? Icons.stop : Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isStreaming;

  const _MessageBubble({
    required this.message,
    required this.isUser,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.space12),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.all(DesignTokens.space12),
            decoration: BoxDecoration(
              color: isUser
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(DesignTokens.radiusLg),
                topRight: const Radius.circular(DesignTokens.radiusLg),
                bottomLeft: Radius.circular(
                  isUser ? DesignTokens.radiusLg : DesignTokens.radiusXs,
                ),
                bottomRight: Radius.circular(
                  isUser ? DesignTokens.radiusXs : DesignTokens.radiusLg,
                ),
              ),
            ),
            child: isUser
                ? Text(
                    message,
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  )
                : MarkdownBody(
                    data: message + (isStreaming ? ' ▌' : ''),
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(color: colorScheme.onSurface),
                      code: TextStyle(
                        backgroundColor:
                            colorScheme.surfaceContainerHighest,
                        color: colorScheme.primary,
                        fontSize: 13,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusSm,
                        ),
                      ),
                      h1: TextStyle(color: colorScheme.onSurface),
                      h2: TextStyle(color: colorScheme.onSurface),
                      h3: TextStyle(color: colorScheme.onSurface),
                      a: TextStyle(color: colorScheme.primary),
                    ),
                  ),
          ),
          if (isStreaming)
            Padding(
              padding: const EdgeInsets.only(top: DesignTokens.space4),
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
