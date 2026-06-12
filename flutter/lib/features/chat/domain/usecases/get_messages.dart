import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetMessagesParams extends Equatable {
  final String conversationId;

  const GetMessagesParams({required this.conversationId});

  @override
  List<Object> get props => [conversationId];
}

class GetMessages extends UseCase<List<Message>, GetMessagesParams> {
  final ChatRepository repository;

  GetMessages(this.repository);

  @override
  Future<Either<Failure, List<Message>>> call(GetMessagesParams params) {
    return repository.getMessages(params.conversationId);
  }
}
