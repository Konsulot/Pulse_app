import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../features/auth/data/auth_repository.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return AuthRepository(client);
});

final currentUserProvider = Provider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.currentUser;
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;
  AuthController(this._repository) : super(const AsyncData(null));

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.signIn(email: email, password: password);
    });
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.sendPasswordResetEmail(email);
    });
  }

  Future<void> updatePassword(String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.updatePassword(password);
    });
  }

  Future<void> signOut() async {
    // Не переводим общий auth-state в loading при выходе.
    // Иначе экраны успевают перестроиться и показать промежуточные
    // сообщения про права/привязку до перехода на экран входа.
    await _repository.signOut();
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});
