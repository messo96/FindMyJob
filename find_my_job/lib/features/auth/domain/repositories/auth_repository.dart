import '../entities/app_user.dart';
import '../../../../core/errors/failure.dart';

/// Abstract repository for authentication operations.
/// Implementations: [FirebaseAuthRepository] (phase 3), [MockAuthRepository] (phase 2).
abstract class AuthRepository {
  /// Stream of the current authenticated user. Emits null when signed out.
  Stream<AppUser?> get authStateChanges;

  /// Returns the currently signed-in user, or null.
  AppUser? get currentUser;

  /// Sign in with email and password.
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with Google OAuth.
  Future<AppUser> signInWithGoogle();

  /// Register a new user with email and password.
  /// Does NOT set role — role is set via [setUserRole] after registration.
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Set the role for a newly registered user (called once after sign-up).
  Future<void> setUserRole(UserRole role);

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email);

  /// Sign out the current user.
  Future<void> signOut();

  /// Delete the current user account.
  Future<void> deleteAccount();

  /// Update FCM token for push notifications.
  Future<void> updateFcmToken(String token);
}

/// Typed exception wrapping auth failures.
class AuthException implements Exception {
  final Failure failure;
  const AuthException(this.failure);

  @override
  String toString() => 'AuthException: ${failure.message}';
}
