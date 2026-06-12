import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../errors/failure.dart';

abstract class UseCase<T, Params> {
  FutureOr<Either<Failure, T>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
