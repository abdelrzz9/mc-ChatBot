import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../di/injection_container.dart' as di;
import '../domain/repositories/auth_repository.dart';
import '../presentation/controllers/auth_controller.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(repository: di.sl<AuthRepository>());
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).status == AuthStatus.authenticated;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).error;
});

final authUserProvider = Provider<AuthTokens?>((ref) {
  return null;
});
