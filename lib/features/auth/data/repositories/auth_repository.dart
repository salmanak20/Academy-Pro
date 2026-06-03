import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/app_user.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.idTokenChanges();

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return fetchUserData(user.uid);
  }

  Future<AppUser?> fetchUserData(String uid) async {
    try {
      print('DEBUG: Fetching user data for UID: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        print('DEBUG: User doc does not exist or data is null');
        return null;
      }
      print('DEBUG: Successfully fetched user data: ${doc.data()}');
      return AppUser.fromJson({'uid': uid, ...doc.data()!});
    } catch (e) {
      print('DEBUG: Error in fetchUserData: $e');
      rethrow;
    }
  }

  Future<AppUser?> signInWithEmailPassword(String email, String password) async {
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase is not initialized. Check production configuration.');
    }

    try {
      print('DEBUG: Starting signInWithEmailAndPassword');
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = userCredential.user;
      if (user == null) {
         print('DEBUG: User returned from signIn is null');
         return null;
      }
      
      print('DEBUG: User signed in successfully. UID: ${user.uid}');
      final appUser = await fetchUserData(user.uid);
      
      if (appUser != null && appUser.role == 'Principal' && appUser.academyId != null) {
        print('DEBUG: User is principal. Fetching academy info for: ${appUser.academyId}');
        final academyDoc = await _firestore.collection('academies').doc(appUser.academyId).get();
        if (academyDoc.exists && academyDoc.data()?['status'] == 'disabled') {
          print('DEBUG: Academy is disabled. Signing out.');
          await _auth.signOut();
          throw Exception('Your academy account is disabled. Contact support.');
        }
      }
      
      if (appUser == null) {
        print('DEBUG: AppUser is null. Signing out.');
        await _auth.signOut();
        throw Exception('Your account profile is missing. Contact support.');
      }
      return appUser;
    } on FirebaseAuthException catch (e) {
      print('DEBUG: FirebaseAuthException: ${e.code}');
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Invalid email or password');
      } else if (e.code == 'invalid-email') {
        throw Exception("The email isn't valid. Try a different email.");
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled.');
      } else {
        throw Exception('Authentication failed. Please try again.');
      }
    } catch (e) {
      print('DEBUG: Generic exception during login: $e');
      if (e is Exception) rethrow;
      throw Exception('Login failed. Please try again later.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository();
}
