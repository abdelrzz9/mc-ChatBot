import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/injection_container.dart';
import '../domain/repositories/chat_repository.dart';
import '../presentation/controllers/chat_controller.dart';
import '../presentation/controllers/conversation_list_controller.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return sl<ChatRepository>();
});

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(ref.watch(chatRepositoryProvider));
});

final conversationListControllerProvider =
    StateNotifierProvider<ConversationListController, ConversationListState>(
  (ref) {
    return ConversationListController(ref.watch(chatRepositoryProvider));
  },
);
