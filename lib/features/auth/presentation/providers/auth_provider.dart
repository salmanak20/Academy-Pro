import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/app_user.dart';
import 'dart:async';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<AppUser?> build() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      // Aggressive timeout for initial user check
      return await repo.getCurrentUser().timeout(
        const Duration(seconds: 7),
        onTimeout: () {
          print('DEBUG: AuthController.build timed out after 7s');
          return null;
        },
      );
    } catch (e) {
      print('DEBUG: AuthController.build error: $e');
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signInWithEmailPassword(email, password);
      state = AsyncValue.data(user);
    } catch (e) {
      state = const AsyncValue.data(null);
      rethrow;
    }
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AsyncValue.data(null);
  }
}
