import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/app_user.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<AppUser?> build() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      // Add a timeout to prevent hanging on splash screen if Firebase/Firestore is unresponsive
      return await repo.getCurrentUser().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('DEBUG: AuthController build timed out');
          return null;
        },
      );
    } catch (e) {
      print('DEBUG: AuthController build error: $e');
      // Return null if Firebase is not initialized or error occurs to avoid getting stuck
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
      // Reset to unauthenticated so the router doesn't get stuck on splash
      state = const AsyncValue.data(null);
      // Re-throw so the login screen UI can catch and display the error
      rethrow;
    }
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AsyncValue.data(null);
  }
}
