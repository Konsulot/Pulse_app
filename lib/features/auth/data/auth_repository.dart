import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  static const resetPasswordRedirectUrl = 'patientsapp://auth/reset-password';

  final SupabaseClient client;
  AuthRepository(this.client);

  Session? get currentSession => client.auth.currentSession;
  User? get currentUser => client.auth.currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName.trim(),
      },
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await client.auth.resetPasswordForEmail(
      email,
      redirectTo: resetPasswordRedirectUrl,
    );
  }

  Future<void> updatePassword(String password) async {
    await client.auth.updateUser(
      UserAttributes(password: password),
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
