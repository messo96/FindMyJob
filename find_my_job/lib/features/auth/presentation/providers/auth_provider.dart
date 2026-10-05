import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_user.dart';
import '../../data/repositories/firebase_auth_repository_impl.dart';

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final repo = ref.watch(firebaseAuthRepositoryProvider);
    // Listen to Firebase auth stream and update the state
    final stream = repo.authStateChanges;
    
    // We use await to get the initial value
    return await stream.first; 
  }

  // To keep state updated continuously we should actually just watch the stream
  // but since we need methods, let's keep it simple. Actually, Riverpod AsyncNotifier
  // handles streams via stream.listen in build, or we can just update state manually.
  // The correct Riverpod 2.x way to listen to a stream in an AsyncNotifier:
  
  /*
  @override
  Stream<AppUser?> build() {
    return ref.watch(firebaseAuthRepositoryProvider).authStateChanges;
  }
  */
  // But wait, the signature in Phase 2 was AsyncNotifier<AppUser?> returning Future.
  // Let's just make it a StreamNotifier. Wait, changing base class requires changes in UI?
  // `AsyncValue<AppUser?>` is the same for both AsyncNotifier and StreamNotifier.
  // I will use AsyncNotifier and just update state after calls.

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(firebaseAuthRepositoryProvider);
      final user = await repo.signInWithEmail(email: email, password: password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(firebaseAuthRepositoryProvider);
      final user = await repo.signUpWithEmail(email: email, password: password, displayName: name);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> setRole(UserRole role) async {
    try {
      final repo = ref.read(firebaseAuthRepositoryProvider);
      await repo.setUserRole(role);
      // Update local state to reflect role change immediately
      final curr = state.value;
      if (curr != null) {
        state = AsyncValue.data(curr.copyWith(role: role));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final repo = ref.read(firebaseAuthRepositoryProvider);
      await repo.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      rethrow;
    }
  }
}

// A StreamProvider for real-time auth state (useful for routing)
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(firebaseAuthRepositoryProvider).authStateChanges;
});
