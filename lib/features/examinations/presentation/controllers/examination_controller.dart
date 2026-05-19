import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/examinations_repository.dart';
import '../../domain/exam_e42_model.dart';
import '../../domain/exam_energy_model.dart';
import '../../domain/exam_foot_model.dart';
import '../../domain/exam_p9_model.dart';
import '../../domain/exam_star1_model.dart';
import '../../domain/exam_star2_model.dart';
import '../../domain/examination_model.dart';
import '../../domain/current_examination_model.dart';
import '../../domain/examination_result_model.dart';

final examinationsRepositoryProvider = Provider<ExaminationsRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return ExaminationsRepository(client);
});

final currentExaminationsProvider = FutureProvider<List<CurrentExaminationModel>>((ref) async {
  final repo = ref.watch(examinationsRepositoryProvider);
  return repo.getCurrentExaminations();
});

final patientExaminationsProvider =
    FutureProvider.family<List<ExaminationModel>, String>((ref, patientId) async {
  final repo = ref.watch(examinationsRepositoryProvider);
  return repo.getPatientExaminations(patientId);
});

class CreateExaminationController extends StateNotifier<AsyncValue<ExaminationModel?>> {
  final ExaminationsRepository _repository;
  final Ref _ref;
  CreateExaminationController(this._repository, this._ref) : super(const AsyncData(null));

  Future<ExaminationModel?> createExamination({required String patientId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final examination = await _repository.createExamination(patientId: patientId);
      _ref.invalidate(patientExaminationsProvider(patientId));
      _ref.invalidate(currentExaminationsProvider);
      return examination;
    });
    return state.value;
  }
}

final createExaminationControllerProvider =
    StateNotifierProvider<CreateExaminationController, AsyncValue<ExaminationModel?>>((ref) {
  final repo = ref.watch(examinationsRepositoryProvider);
  return CreateExaminationController(repo, ref);
});

class SaveStar1Controller extends StateNotifier<AsyncValue<void>> {
  final ExaminationsRepository _repository;
  final Ref _ref;
  SaveStar1Controller(this._repository, this._ref) : super(const AsyncData(null));
  Future<void> save(ExamStar1Model model) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.saveStar1(model);
      _ref.invalidate(star1DataProvider(model.examinationId));
      _ref.invalidate(examinationResultProvider(model.examinationId));
      _ref.invalidate(examinationResumeRouteProvider(model.examinationId));
      final patientId = await _repository.getPatientIdByExamination(model.examinationId);
      if (patientId != null) _ref.invalidate(patientExaminationsProvider(patientId));
      _ref.invalidate(currentExaminationsProvider);
    });
  }
}
final saveStar1ControllerProvider =
    StateNotifierProvider<SaveStar1Controller, AsyncValue<void>>((ref) {
  final repo = ref.watch(examinationsRepositoryProvider);
  return SaveStar1Controller(repo, ref);
});

class SaveStar2Controller extends StateNotifier<AsyncValue<void>> {
  final ExaminationsRepository _repository;
  final Ref _ref;
  SaveStar2Controller(this._repository, this._ref) : super(const AsyncData(null));
  Future<void> save(ExamStar2Model model) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.saveStar2(model);
      _ref.invalidate(star2DataProvider(model.examinationId));
      _ref.invalidate(examinationResultProvider(model.examinationId));
      _ref.invalidate(examinationResumeRouteProvider(model.examinationId));
      final patientId = await _repository.getPatientIdByExamination(model.examinationId);
      if (patientId != null) _ref.invalidate(patientExaminationsProvider(patientId));
      _ref.invalidate(currentExaminationsProvider);
    });
  }
}
final saveStar2ControllerProvider =
    StateNotifierProvider<SaveStar2Controller, AsyncValue<void>>((ref) {
  final repo = ref.watch(examinationsRepositoryProvider);
  return SaveStar2Controller(repo, ref);
});

class SaveEnergyController extends StateNotifier<AsyncValue<void>> {
  final ExaminationsRepository _repository;
  final Ref _ref;
  SaveEnergyController(this._repository, this._ref) : super(const AsyncData(null));
  Future<void> save(ExamEnergyModel model) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.saveEnergy(model);
      _ref.invalidate(energyDataProvider(model.examinationId));
      _ref.invalidate(examinationResultProvider(model.examinationId));
      _ref.invalidate(examinationResumeRouteProvider(model.examinationId));
      final patientId = await _repository.getPatientIdByExamination(model.examinationId);
      if (patientId != null) _ref.invalidate(patientExaminationsProvider(patientId));
      _ref.invalidate(currentExaminationsProvider);
    });
  }
}
final saveEnergyControllerProvider =
    StateNotifierProvider<SaveEnergyController, AsyncValue<void>>((ref) {
  final repo = ref.watch(examinationsRepositoryProvider);
  return SaveEnergyController(repo, ref);
});

class SaveP9Controller extends StateNotifier<AsyncValue<void>> {
  final ExaminationsRepository _repository;
  final Ref _ref;
  SaveP9Controller(this._repository, this._ref) : super(const AsyncData(null));
  Future<void> save(ExamP9Model model) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.saveP9(model);
      _ref.invalidate(p9DataProvider(model.examinationId));
      _ref.invalidate(examinationResultProvider(model.examinationId));
      _ref.invalidate(examinationResumeRouteProvider(model.examinationId));
      final patientId = await _repository.getPatientIdByExamination(model.examinationId);
      if (patientId != null) _ref.invalidate(patientExaminationsProvider(patientId));
      _ref.invalidate(currentExaminationsProvider);
    });
  }
}
final saveP9ControllerProvider =
    StateNotifierProvider<SaveP9Controller, AsyncValue<void>>((ref) {
  final repo = ref.watch(examinationsRepositoryProvider);
  return SaveP9Controller(repo, ref);
});

class SaveE42Controller extends StateNotifier<AsyncValue<void>> {
  final ExaminationsRepository _repository;
  final Ref _ref;
  SaveE42Controller(this._repository, this._ref) : super(const AsyncData(null));
  Future<void> save(ExamE42Model model) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.saveE42(model);
      _ref.invalidate(e42DataProvider(model.examinationId));
      _ref.invalidate(examinationResultProvider(model.examinationId));
      _ref.invalidate(examinationResumeRouteProvider(model.examinationId));
      final patientId = await _repository.getPatientIdByExamination(model.examinationId);
      if (patientId != null) _ref.invalidate(patientExaminationsProvider(patientId));
      _ref.invalidate(currentExaminationsProvider);
    });
  }
}
final saveE42ControllerProvider =
    StateNotifierProvider<SaveE42Controller, AsyncValue<void>>((ref) {
  final repo = ref.watch(examinationsRepositoryProvider);
  return SaveE42Controller(repo, ref);
});

class SaveFootController extends StateNotifier<AsyncValue<void>> {
  final ExaminationsRepository _repository;
  final Ref _ref;
  SaveFootController(this._repository, this._ref) : super(const AsyncData(null));
  Future<void> save(ExamFootModel model) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.saveFoot(model);
      _ref.invalidate(footDataProvider(model.examinationId));
      _ref.invalidate(examinationResultProvider(model.examinationId));
      _ref.invalidate(examinationResumeRouteProvider(model.examinationId));
      final patientId = await _repository.getPatientIdByExamination(model.examinationId);
      if (patientId != null) _ref.invalidate(patientExaminationsProvider(patientId));
      _ref.invalidate(currentExaminationsProvider);
    });
  }
}
final saveFootControllerProvider =
    StateNotifierProvider<SaveFootController, AsyncValue<void>>((ref) {
  final repo = ref.watch(examinationsRepositoryProvider);
  return SaveFootController(repo, ref);
});

final examinationResultProvider =
    FutureProvider.family<ExaminationResultModel, String>((ref, examinationId) async {
  final repo = ref.watch(examinationsRepositoryProvider);
  return repo.getResult(examinationId);
});

final examinationResumeRouteProvider = FutureProvider.family<String, String>((ref, examinationId) async {
  final repo = ref.watch(examinationsRepositoryProvider);
  return repo.getResumeRoute(examinationId);
});

final examinationPatientIdProvider = FutureProvider.family<String?, String>((ref, examinationId) async {
  final repo = ref.watch(examinationsRepositoryProvider);
  return repo.getPatientIdByExamination(examinationId);
});

final star1DataProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final repo = ref.watch(examinationsRepositoryProvider);
  return repo.getModule('exam_star1', id);
});
final star2DataProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final repo = ref.watch(examinationsRepositoryProvider);
  return repo.getModule('exam_star2', id);
});
final energyDataProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final repo = ref.watch(examinationsRepositoryProvider);
  return repo.getModule('exam_energy', id);
});
final p9DataProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final repo = ref.watch(examinationsRepositoryProvider);
  return repo.getModule('exam_p9', id);
});
final e42DataProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final repo = ref.watch(examinationsRepositoryProvider);
  return repo.getModule('exam_e42', id);
});
final footDataProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final repo = ref.watch(examinationsRepositoryProvider);
  return repo.getModule('exam_foot', id);
});

class CompleteExaminationController extends StateNotifier<AsyncValue<void>> {
  final ExaminationsRepository _repository;
  final Ref _ref;
  CompleteExaminationController(this._repository, this._ref) : super(const AsyncData(null));

  Future<void> complete(String examinationId, {String? patientId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.completeExamination(examinationId);
      if (patientId != null) {
        _ref.invalidate(patientExaminationsProvider(patientId));
      }
      _ref.invalidate(currentExaminationsProvider);
    });
  }
}
final completeExaminationControllerProvider =
    StateNotifierProvider<CompleteExaminationController, AsyncValue<void>>((ref) {
  final repo = ref.watch(examinationsRepositoryProvider);
  return CompleteExaminationController(repo, ref);
});

class DeleteExaminationController extends StateNotifier<AsyncValue<void>> {
  final ExaminationsRepository _repository;
  final Ref _ref;
  DeleteExaminationController(this._repository, this._ref) : super(const AsyncData(null));

  Future<void> delete({required String examinationId, String? patientId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteExamination(examinationId);
      _ref.invalidate(examinationResultProvider(examinationId));
      _ref.invalidate(star1DataProvider(examinationId));
      _ref.invalidate(star2DataProvider(examinationId));
      _ref.invalidate(energyDataProvider(examinationId));
      _ref.invalidate(p9DataProvider(examinationId));
      _ref.invalidate(e42DataProvider(examinationId));
      _ref.invalidate(footDataProvider(examinationId));
      if (patientId != null) _ref.invalidate(patientExaminationsProvider(patientId));
      _ref.invalidate(currentExaminationsProvider);
    });
  }
}
final deleteExaminationControllerProvider =
    StateNotifierProvider<DeleteExaminationController, AsyncValue<void>>((ref) {
  final repo = ref.watch(examinationsRepositoryProvider);
  return DeleteExaminationController(repo, ref);
});
