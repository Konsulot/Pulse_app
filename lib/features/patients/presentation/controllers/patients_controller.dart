import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/patients_repository.dart';
import '../../domain/patient_model.dart';

final patientsRepositoryProvider = Provider<PatientsRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return PatientsRepository(client);
});

final patientSearchQueryProvider = StateProvider<String>((ref) => '');

final patientsListProvider = FutureProvider<List<PatientModel>>((ref) async {
  final repo = ref.watch(patientsRepositoryProvider);
  final patients = await repo.getPatients();
  final query = ref.watch(patientSearchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return patients;
  return patients.where((patient) {
    final text = [
      patient.fullName,
      patient.cardNumber,
      patient.polis,
      patient.snils,
      patient.insuranceOrgName,
      patient.education,
      patient.city,
      patient.street,
    ].whereType<String>().join(' ').toLowerCase();
    return text.contains(query);
  }).toList();
});

final patientDetailsProvider = FutureProvider.family<PatientModel, String>((ref, patientId) async {
  final repo = ref.watch(patientsRepositoryProvider);
  return repo.getPatientById(patientId);
});

class CreatePatientController extends StateNotifier<AsyncValue<void>> {
  final PatientsRepository _repository;
  final Ref _ref;
  CreatePatientController(this._repository, this._ref) : super(const AsyncData(null));

  Future<void> createPatient({
    required String cardNumber,
    required String lastName,
    required String firstName,
    String? middleName,
    DateTime? birthDate,
    String? polis,
    String? snils,
    int? genderId,
    String? region,
    String? city,
    String? street,
    int? house,
    int? room,
    int? postalIndex,
    String? job,
    String? jobTitle,
    bool? isDisabled,
    String? insuranceOrgName,
    String? education,
    int? disabilityGroup,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.createPatient(
        cardNumber: cardNumber,
        lastName: lastName,
        firstName: firstName,
        middleName: middleName,
        birthDate: birthDate,
        polis: polis,
        snils: snils,
        genderId: genderId,
        region: region,
        city: city,
        street: street,
        house: house,
        room: room,
        postalIndex: postalIndex,
        job: job,
        jobTitle: jobTitle,
        isDisabled: isDisabled,
        insuranceOrgName: insuranceOrgName,
        education: education,
        disabilityGroup: disabilityGroup,
      );
      _ref.invalidate(patientsListProvider);
    });
  }
}

final createPatientControllerProvider =
    StateNotifierProvider<CreatePatientController, AsyncValue<void>>((ref) {
  final repo = ref.watch(patientsRepositoryProvider);
  return CreatePatientController(repo, ref);
});

class UpdatePatientController extends StateNotifier<AsyncValue<void>> {
  final PatientsRepository _repository;
  final Ref _ref;
  UpdatePatientController(this._repository, this._ref) : super(const AsyncData(null));

  Future<void> updatePatient({
    required String id,
    required String cardNumber,
    required String lastName,
    required String firstName,
    String? middleName,
    DateTime? birthDate,
    String? polis,
    String? snils,
    int? genderId,
    String? region,
    String? city,
    String? street,
    int? house,
    int? room,
    int? postalIndex,
    String? job,
    String? jobTitle,
    bool? isDisabled,
    String? insuranceOrgName,
    String? education,
    int? disabilityGroup,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.updatePatient(
        id: id,
        cardNumber: cardNumber,
        lastName: lastName,
        firstName: firstName,
        middleName: middleName,
        birthDate: birthDate,
        polis: polis,
        snils: snils,
        genderId: genderId,
        region: region,
        city: city,
        street: street,
        house: house,
        room: room,
        postalIndex: postalIndex,
        job: job,
        jobTitle: jobTitle,
        isDisabled: isDisabled,
        insuranceOrgName: insuranceOrgName,
        education: education,
        disabilityGroup: disabilityGroup,
      );
      _ref.invalidate(patientsListProvider);
      _ref.invalidate(patientDetailsProvider(id));
    });
  }
}

final updatePatientControllerProvider =
    StateNotifierProvider<UpdatePatientController, AsyncValue<void>>((ref) {
  final repo = ref.watch(patientsRepositoryProvider);
  return UpdatePatientController(repo, ref);
});

class DeletePatientController extends StateNotifier<AsyncValue<void>> {
  final PatientsRepository _repository;
  final Ref _ref;
  DeletePatientController(this._repository, this._ref) : super(const AsyncData(null));

  Future<void> deletePatient(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deletePatient(id);
      _ref.invalidate(patientsListProvider);
    });
  }
}

final deletePatientControllerProvider =
    StateNotifierProvider<DeletePatientController, AsyncValue<void>>((ref) {
  final repo = ref.watch(patientsRepositoryProvider);
  return DeletePatientController(repo, ref);
});
