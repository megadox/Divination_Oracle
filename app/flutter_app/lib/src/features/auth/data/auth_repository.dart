import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Future<User> signInAnonymously() async {
    final response = await _client.auth.signInAnonymously();
    final user = response.user;
    if (user == null) {
      throw const AuthException('Anonymous sign-in failed.');
    }
    await _client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'is_anonymous': true,
    });
    return user;
  }
}
