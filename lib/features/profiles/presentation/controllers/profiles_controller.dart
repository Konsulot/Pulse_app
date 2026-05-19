import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/profiles_repository.dart';
import '../../domain/doctor_profile_model.dart';
import '../../domain/profile_model.dart';

final profilesRepositoryProvider = Provider<ProfilesRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return ProfilesRepository(client);
});

final currentProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  ref.watch(authControllerProvider);
  final repo = ref.watch(profilesRepositoryProvider);
  return repo.getCurrentProfile();
});

final currentDoctorProfileProvider = FutureProvider<DoctorProfileModel?>((ref) async {
  ref.watch(currentProfileProvider);
  final repo = ref.watch(profilesRepositoryProvider);
  return repo.getCurrentDoctorProfile();
});

class UpdateDoctorProfileController extends StateNotifier<AsyncValue<void>> {
  final ProfilesRepository _repository;
  final Ref _ref;
  UpdateDoctorProfileController(this._repository, this._ref) : super(const AsyncData(null));

  Future<void> save({
    required String lastName,
    required String firstName,
    String? middleName,
    String? specialization,
    DateTime? birthDate,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.saveCurrentDoctorProfile(
        lastName: lastName,
        firstName: firstName,
        middleName: middleName,
        specialization: specialization,
        birthDate: birthDate,
      );
      _ref.invalidate(currentProfileProvider);
      _ref.invalidate(currentDoctorProfileProvider);
    });
  }
}

final updateDoctorProfileControllerProvider =
    StateNotifierProvider<UpdateDoctorProfileController, AsyncValue<void>>((ref) {
  final repo = ref.watch(profilesRepositoryProvider);
  return UpdateDoctorProfileController(repo, ref);
});
