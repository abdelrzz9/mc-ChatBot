import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/repositories/chat_repository.dart';

class ConversationListState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;

  const ConversationListState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationListState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ConversationListState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }

  static const initial = ConversationListState();
}

class ConversationListController
    extends StateNotifier<ConversationListState> {
  final ChatRepository _repository;

  ConversationListController(this._repository)
      : super(ConversationListState.initial);

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getConversations();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (conversations) => state = state.copyWith(
        conversations: conversations,
        isLoading: false,
      ),
    );
  }

  Future<void> createConversation(String title) async {
    final result = await _repository.createConversation(title);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (conversation) => state = state.copyWith(
        conversations: [conversation, ...state.conversations],
      ),
    );
  }

  Future<void> deleteConversation(String id) async {
    final result = await _repository.deleteConversation(id);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => state = state.copyWith(
        conversations:
            state.conversations.where((c) => c.id != id).toList(),
      ),
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
