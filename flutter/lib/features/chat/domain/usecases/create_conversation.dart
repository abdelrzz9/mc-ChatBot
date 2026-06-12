import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class CreateConversationParams extends Equatable {
  final String title;

  const CreateConversationParams({required this.title});

  @override
  List<Object> get props => [title];
}

class CreateConversation extends UseCase<Conversation, CreateConversationParams> {
  final ChatRepository repository;

  CreateConversation(this.repository);

  @override
  Future<Either<Failure, Conversation>> call(CreateConversationParams params) {
    return repository.createConversation(params.title);
  }
}
