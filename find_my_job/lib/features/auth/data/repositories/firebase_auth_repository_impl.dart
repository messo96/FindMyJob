import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  FirebaseAuthRepositoryImpl({
    required auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  final auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AppUser? _cachedUser;

  @override
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().switchMap((user) {
      if (user == null) {
        _cachedUser = null;
        return Stream.value(null);
      }
      return _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
        if (!doc.exists) {
          // Document non esiste ancora, aspettiamo
          return null;
        }
        final data = doc.data()!;
        _cachedUser = AppUser(
          uid: doc.id,
          email: data['email'] as String,
          role: UserRole.fromString(data['role'] as String),
          displayName: data['displayName'] as String?,
          photoUrl: data['photoUrl'] as String?,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
        return _cachedUser;
      });
    });
  }

  @override
  AppUser? get currentUser => _cachedUser;

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fetchUserDoc(cred.user!.uid);
    } on auth.FirebaseAuthException catch (e) {
      throw AuthException(AuthFailure(e.message ?? 'Errore di accesso'));
    } catch (e) {
      throw AuthException(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;
      
      // Default to candidate, update via setUserRole
      final now = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'role': UserRole.candidate.name, // Temporary
        'createdAt': now,
        'updatedAt': now,
      });

      return await _fetchUserDoc(uid);
    } on auth.FirebaseAuthException catch (e) {
      throw AuthException(AuthFailure(e.message ?? 'Errore di registrazione'));
    } catch (e) {
      throw AuthException(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<void> setUserRole(UserRole role) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw const AuthException(AuthFailure('Non autenticato'));
    
    await _firestore.collection('users').doc(user.uid).update({
      'role': role.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    // Phase 3 google sign in logic placeholder
    throw UnimplementedError('Google Sign-In non ancora implementato');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    _cachedUser = null;
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    // Da implementare con attenzione eliminando anche dati in Firestore
    throw UnimplementedError('Eliminazione account non implementata');
  }

  @override
  Future<void> updateFcmToken(String token) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    }
  }

  Future<AppUser> _fetchUserDoc(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw const AuthException(NotFoundFailure('Profilo utente'));
    }
    final data = doc.data()!;
    return AppUser(
      uid: doc.id,
      email: data['email'] as String,
      role: UserRole.fromString(data['role'] as String),
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

final firebaseAuthProvider = Provider((ref) => auth.FirebaseAuth.instance);
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final firebaseAuthRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepositoryImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});
