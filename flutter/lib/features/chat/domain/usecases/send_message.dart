import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/chat_repository.dart';

class SendMessageParams extends Equatable {
  final String conversationId;
  final String content;

  const SendMessageParams({
    required this.conversationId,
    required this.content,
  });

  @override
  List<Object> get props => [conversationId, content];
}

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Stream<Either<Failure, String>> call(SendMessageParams params) {
    return repository.sendMessage(params.conversationId, params.content);
  }
}
