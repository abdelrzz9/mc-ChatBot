import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatState {
  final Conversation? currentConversation;
  final List<Message> messages;
  final String? currentResponse;
  final bool isLoading;
  final bool isStreaming;
  final String? error;

  const ChatState({
    this.currentConversation,
    this.messages = const [],
    this.currentResponse,
    this.isLoading = false,
    this.isStreaming = false,
    this.error,
  });

  ChatState copyWith({
    Conversation? currentConversation,
    List<Message>? messages,
    String? currentResponse,
    bool? isLoading,
    bool? isStreaming,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      currentConversation: currentConversation ?? this.currentConversation,
      messages: messages ?? this.messages,
      currentResponse: currentResponse,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      error: clearError ? null : error ?? this.error,
    );
  }

  static const initial = ChatState();
}

class ChatController extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  StreamSubscription<Either<Failure, String>>? _streamSubscription;

  ChatController(this._repository) : super(ChatState.initial);

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getConversations();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (conversations) => state = state.copyWith(isLoading: false),
    );
  }

  Future<void> selectConversation(String id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      currentResponse: null,
      isStreaming: false,
    );
    _streamSubscription?.cancel();

    final results = await Future.wait([
      _repository.getConversations(),
      _repository.getMessages(id),
    ]);

    final conversationsResult =
        results[0] as Either<Failure, List<Conversation>>;
    final messagesResult = results[1] as Either<Failure, List<Message>>;

    Conversation? conversation;
    conversationsResult.fold(
      (_) {},
      (convs) {
        conversation = convs.where((c) => c.id == id).firstOrNull;
      },
    );

    messagesResult.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (messages) => state = state.copyWith(
        currentConversation: conversation,
        messages: messages,
        isLoading: false,
      ),
    );
  }

  Future<void> sendMessage(String content) async {
    if (state.currentConversation == null) return;

    final userMessage = Message(
      id: '',
      role: 'user',
      content: content,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: false,
      isStreaming: true,
      currentResponse: '',
      clearError: true,
    );

    _streamSubscription = _repository
        .sendMessage(state.currentConversation!.id, content)
        .listen(
      (either) {
        either.fold(
          (failure) => state = state.copyWith(
            isStreaming: false,
            error: failure.message,
          ),
          (token) {
            state = state.copyWith(
              currentResponse: (state.currentResponse ?? '') + token,
            );
          },
        );
      },
      onDone: () {
        final response = state.currentResponse ?? '';
        if (response.isNotEmpty) {
          final assistantMessage = Message(
            id: '',
            role: 'assistant',
            content: response,
          );
          state = state.copyWith(
            isStreaming: false,
            messages: [...state.messages, assistantMessage],
            currentResponse: null,
          );
        } else {
          state = state.copyWith(isStreaming: false, currentResponse: null);
        }
      },
      onError: (e) {
        state = state.copyWith(
          isStreaming: false,
          error: e.toString(),
        );
      },
    );
  }

  Future<void> createConversation(String title) async {
    final result = await _repository.createConversation(title);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {},
    );
  }

  Future<void> deleteConversation(String id) async {
    final result = await _repository.deleteConversation(id);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {},
    );
  }

  void cancelStreaming() {
    _streamSubscription?.cancel();
    state = state.copyWith(isStreaming: false);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
