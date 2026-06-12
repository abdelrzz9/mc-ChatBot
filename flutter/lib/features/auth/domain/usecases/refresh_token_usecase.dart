import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase extends UseCase<AuthTokens, RefreshTokenParams> {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  @override
  Future<Either<Failure, AuthTokens>> call(RefreshTokenParams params) async {
    return repository.refreshToken(params.token);
  }
}

class RefreshTokenParams extends Equatable {
  final String token;

  const RefreshTokenParams({required this.token});

  @override
  List<Object> get props => [token];
}
