import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/chat_repository.dart';

class DeleteConversationParams extends Equatable {
  final String id;

  const DeleteConversationParams({required this.id});

  @override
  List<Object> get props => [id];
}

class DeleteConversation extends UseCase<void, DeleteConversationParams> {
  final ChatRepository repository;

  DeleteConversation(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteConversationParams params) {
    return repository.deleteConversation(params.id);
  }
}
