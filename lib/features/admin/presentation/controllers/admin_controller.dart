import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/admin_repository.dart';
import '../../domain/admin_models.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return AdminRepository(client);
});

final adminClinicsProvider = FutureProvider<List<ClinicAdminModel>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getClinics();
});

final adminDoctorsProvider = FutureProvider<List<DoctorAdminModel>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getDoctors();
});

final adminClinicSearchProvider = StateProvider<String>((ref) => '');

final adminDoctorSearchProvider = StateProvider<String>((ref) => '');

class AdminClinicController extends StateNotifier<AsyncValue<void>> {
  final AdminRepository _repository;
  final Ref _ref;

  AdminClinicController(this._repository, this._ref) : super(const AsyncData(null));

  Future<void> create({
    required String shortName,
    String? fullName,
    String? address,
    String? phone,
    String? email,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.createClinic(
        shortName: shortName,
        fullName: fullName,
        address: address,
        phone: phone,
        email: email,
      );
      _ref.invalidate(adminClinicsProvider);
    });
  }

  Future<void> update({
    required String clinicId,
    required String shortName,
    String? fullName,
    String? address,
    String? phone,
    String? email,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.updateClinic(
        clinicId: clinicId,
        shortName: shortName,
        fullName: fullName,
        address: address,
        phone: phone,
        email: email,
      );
      _ref.invalidate(adminClinicsProvider);
      _ref.invalidate(adminDoctorsProvider);
    });
  }

  Future<void> delete(String clinicId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteClinic(clinicId);
      _ref.invalidate(adminClinicsProvider);
      _ref.invalidate(adminDoctorsProvider);
    });
  }
}

final adminClinicControllerProvider =
    StateNotifierProvider<AdminClinicController, AsyncValue<void>>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return AdminClinicController(repo, ref);
});

class AssignDoctorClinicController extends StateNotifier<AsyncValue<void>> {
  final AdminRepository _repository;
  final Ref _ref;

  AssignDoctorClinicController(this._repository, this._ref) : super(const AsyncData(null));

  Future<void> assign({required String profileId, required String clinicId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.assignDoctorToClinic(profileId: profileId, clinicId: clinicId);
      _ref.invalidate(adminDoctorsProvider);
    });
  }

  Future<void> detach(String profileId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.detachDoctorFromClinic(profileId);
      _ref.invalidate(adminDoctorsProvider);
    });
  }

  Future<void> disableDoctorAccess(String profileId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.disableDoctorAccess(profileId);
      _ref.invalidate(adminDoctorsProvider);
    });
  }

  Future<void> enableDoctorAccess(String profileId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.enableDoctorAccess(profileId);
      _ref.invalidate(adminDoctorsProvider);
    });
  }
}

final assignDoctorClinicControllerProvider =
    StateNotifierProvider<AssignDoctorClinicController, AsyncValue<void>>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return AssignDoctorClinicController(repo, ref);
});
