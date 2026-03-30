import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static bool isValidAdmin(String? email, bool isVerified) {
    return email == adminEmail && isVerified;
  }

  static Future<void> signInWithGoogle(UserRole role) async {
    final account = await GoogleSignIn().signIn();
    if (account == null) return;
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    await _persistRole(userCredential.user, role);
  }

  static Future<void> signInWithGitHub(UserRole role) async {
    final provider = GithubAuthProvider();
    final userCredential = await _auth.signInWithProvider(provider);
    await _persistRole(userCredential.user, role);
  }

  static Future<void> signInWithLinkedIn(UserRole role) async {
    final provider = OAuthProvider('linkedin.com');
    final userCredential = await _auth.signInWithProvider(provider);
    await _persistRole(userCredential.user, role);
  }

  static Future<void> linkProvider(String provider) async {
    final user = _auth.currentUser;
    if (user == null) return;

    switch (provider) {
      case 'google.com':
        final account = await GoogleSignIn().signIn();
        if (account == null) return;
        final auth = await account.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: auth.accessToken,
          idToken: auth.idToken,
        );
        await user.linkWithCredential(credential);
        return;
      case 'github.com':
        await user.linkWithProvider(GithubAuthProvider());
        return;
      case 'linkedin.com':
        await user.linkWithProvider(OAuthProvider('linkedin.com'));
        return;
      default:
        throw UnsupportedError('Unsupported provider: $provider');
    }
  }

  static Future<void> _persistRole(User? user, UserRole role) async {
    if (user == null) return;

    final selectedRole = role == UserRole.admin && !isValidAdmin(user.email, user.emailVerified)
        ? UserRole.student
        : role;

    await _firestore.collection(AppCollections.users).doc(user.uid).set({
      'uid': user.uid,
      'name': user.displayName,
      'email': user.email,
      'role': selectedRole.name,
      'providers': user.providerData.map((e) => e.providerId).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> signOut() => _auth.signOut();
}
