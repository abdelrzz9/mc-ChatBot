import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/storage/app_local_storage.dart';
import '../../../chat/domain/entities/conversation.dart';
import '../../../chat/domain/entities/message.dart';
import '../../../chat/domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

Conversation _modelToConversation(ConversationModel m) => Conversation(
      id: m.id,
      title: m.title,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
    );

Message _modelToMessage(MessageModel m) => Message(
      id: m.id,
      conversationId: m.conversationId,
      role: m.role,
      content: m.content,
      createdAt: m.createdAt,
    );

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final AppLocalStorage localStorage;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorage,
  });

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      final models = await remoteDataSource.getConversations();
      final conversations = models
          .map((e) =>
              _modelToConversation(
                ConversationModel.fromJson(e as Map<String, dynamic>),
              ))
          .toList();
      return Right(conversations);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Conversation>> createConversation(String title) async {
    try {
      final data = await remoteDataSource.createConversation(title);
      final conversation =
          _modelToConversation(ConversationModel.fromJson(data));
      return Right(conversation);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Conversation>> renameConversation(
    String id,
    String title,
  ) async {
    try {
      final data = await remoteDataSource.renameConversation(id, title);
      final conversation =
          _modelToConversation(ConversationModel.fromJson(data));
      return Right(conversation);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(String id) async {
    try {
      await remoteDataSource.deleteConversation(id);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(
    String conversationId,
  ) async {
    try {
      final models = await remoteDataSource.getMessages(conversationId);
      final messages = models
          .map((e) =>
              _modelToMessage(
                MessageModel.fromJson(e as Map<String, dynamic>),
              ))
          .toList();
      return Right(messages);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, String>> sendMessage(
    String conversationId,
    String content,
  ) async* {
    try {
      await for (final token
          in remoteDataSource.sendMessageStream(conversationId, content)) {
        yield Right(token);
      }
    } catch (e) {
      yield Left(ServerFailure(message: e.toString()));
    }
  }
}
