import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Conversation>>> getConversations();
  Future<Either<Failure, Conversation>> createConversation(String title);
  Future<Either<Failure, Conversation>> renameConversation(
    String id,
    String title,
  );
  Future<Either<Failure, void>> deleteConversation(String id);
  Future<Either<Failure, List<Message>>> getMessages(String conversationId);
  Stream<Either<Failure, String>> sendMessage(
    String conversationId,
    String content,
  );
}
