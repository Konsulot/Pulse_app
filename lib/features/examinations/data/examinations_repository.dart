import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/exam_e42_model.dart';
import '../domain/exam_energy_model.dart';
import '../domain/exam_foot_model.dart';
import '../domain/exam_p9_model.dart';
import '../domain/exam_star1_model.dart';
import '../domain/exam_star2_model.dart';
import '../domain/examination_model.dart';
import '../domain/current_examination_model.dart';
import '../domain/examination_result_model.dart';

class ExaminationsRepository {
  final SupabaseClient client;
  ExaminationsRepository(this.client);


  Future<Map<String, dynamic>?> _currentProfile() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    return await client
        .from('profiles')
        .select('clinic_id, doctor_id, full_name')
        .eq('id', user.id)
        .maybeSingle();
  }


  Future<Map<String, String>> _doctorNamesByProfileIds(Iterable<String> ids) async {
    final profileIds = ids.where((id) => id.trim().isNotEmpty).toSet().toList();
    if (profileIds.isEmpty) return <String, String>{};

    final response = await client
        .from('profiles')
        .select('id, full_name')
        .inFilter('id', profileIds);

    return {
      for (final item in response as List)
        if ((item['id']?.toString() ?? '').isNotEmpty)
          item['id'].toString(): (item['full_name']?.toString().trim().isNotEmpty ?? false)
              ? item['full_name'].toString().trim()
              : 'Врач не указан',
    };
  }

  Future<String?> _doctorNameByProfileId(String? id) async {
    if (id == null || id.trim().isEmpty) return null;
    final names = await _doctorNamesByProfileIds([id]);
    return names[id];
  }

  Future<ExaminationModel> createExamination({
    required String patientId,
    DateTime? examDateTime,
  }) async {
    final user = client.auth.currentUser;
    final profile = await _currentProfile();
    final clinicId = profile?['clinic_id']?.toString();
    final doctorId = profile?['doctor_id']?.toString();

    if (clinicId == null || clinicId.isEmpty) {
      throw Exception('Аккаунт не привязан к клинике. Создание обследований недоступно.');
    }

    final response = await client.from('examinations').insert({
      'patient_id': patientId,
      'clinic_id': clinicId,
      'doctor_id': doctorId,
      'created_by': user?.id,
      'exam_datetime': (examDateTime ?? DateTime.now()).toUtc().toIso8601String(),
      'status': 'in_progress',
    }).select().single();
    return ExaminationModel.fromJson(response);
  }


  Future<List<CurrentExaminationModel>> getCurrentExaminations() async {
    final profile = await _currentProfile();
    final clinicId = profile?['clinic_id']?.toString();
    if (clinicId == null || clinicId.isEmpty) return [];

    final response = await client
        .from('examinations')
        .select('id, patient_id, exam_datetime, status, created_by, patients(id, card_number, last_name, first_name, middle_name)')
        .eq('clinic_id', clinicId)
        .order('exam_datetime', ascending: false);

    final rows = (response as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    final doctorNames = await _doctorNamesByProfileIds(
      rows.map((item) => item['created_by']?.toString() ?? ''),
    );

    return rows
        .map((item) {
          item['doctor_name'] = doctorNames[item['created_by']?.toString()];
          return CurrentExaminationModel.fromJson(item);
        })
        .where((exam) => !isCompletedStatus(exam.status))
        .toList();
  }

  Future<List<ExaminationModel>> getPatientExaminations(String patientId) async {
    final response = await client
        .from('examinations')
        .select()
        .eq('patient_id', patientId)
        .order('exam_datetime', ascending: false);

    final rows = (response as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    final doctorNames = await _doctorNamesByProfileIds(
      rows.map((item) => item['created_by']?.toString() ?? ''),
    );

    return rows.map((item) {
      item['doctor_name'] = doctorNames[item['created_by']?.toString()];
      return ExaminationModel.fromJson(item);
    }).toList();
  }

  Future<void> deleteExamination(String examinationId) async {
    await client.from('examinations').delete().eq('id', examinationId);
  }

  Future<void> saveStar1(ExamStar1Model model) async => client.from('exam_star1').upsert(model.toInsertJson(), onConflict: 'examination_id');
  Future<void> saveStar2(ExamStar2Model model) async => client.from('exam_star2').upsert(model.toInsertJson(), onConflict: 'examination_id');
  Future<void> saveEnergy(ExamEnergyModel model) async => client.from('exam_energy').upsert(model.toInsertJson(), onConflict: 'examination_id');
  Future<void> saveP9(ExamP9Model model) async => client.from('exam_p9').upsert(model.toInsertJson(), onConflict: 'examination_id');
  Future<void> saveE42(ExamE42Model model) async => client.from('exam_e42').upsert(model.toInsertJson(), onConflict: 'examination_id');
  Future<void> saveFoot(ExamFootModel model) async => client.from('exam_foot').upsert(model.toInsertJson(), onConflict: 'examination_id');

  Future<void> saveKeyValueRecord({
    required String table,
    required String examinationId,
    required dynamic keyValues,
  }) async {
    await client.from(table).upsert({
      'examination_id': examinationId,
      'key_values': keyValues,
    }, onConflict: 'examination_id');
  }

  Future<Map<String, dynamic>?> getModule(String table, String examinationId) async {
    return await client.from(table).select().eq('examination_id', examinationId).maybeSingle();
  }

  Future<ExaminationResultModel> getResult(String examinationId) async {
    final examination = await client.from('examinations').select().eq('id', examinationId).maybeSingle();
    Map<String, dynamic>? patient;
    final patientId = examination?['patient_id']?.toString();
    if (patientId != null && patientId.isNotEmpty) {
      patient = await client.from('patients').select().eq('id', patientId).maybeSingle();
    }
    final star1 = await getModule('exam_star1', examinationId);
    final star2 = await getModule('exam_star2', examinationId);
    final energy = await getModule('exam_energy', examinationId);
    final p9 = await getModule('exam_p9', examinationId);
    final e42 = await getModule('exam_e42', examinationId);
    final foot = await getModule('exam_foot', examinationId);
    final indexrecord = await getModule('exam_indexrecord', examinationId);
    final crossrecord = await getModule('exam_crossrecord', examinationId);
    final circlerecord = await getModule('exam_circlerecord', examinationId);
    final balancerecord = await getModule('exam_balancerecord', examinationId);
    final doctorName = await _doctorNameByProfileId(examination?['created_by']?.toString());
    return ExaminationResultModel(
      examination: examination,
      patient: patient,
      doctorName: doctorName,
      star1: star1,
      star2: star2,
      energy: energy,
      p9: p9,
      e42: e42,
      foot: foot,
      indexrecord: indexrecord,
      crossrecord: crossrecord,
      circlerecord: circlerecord,
      balancerecord: balancerecord,
    );
  }


  static bool isCompletedStatus(String? status) {
    return status == 'completed' || status == 'завершено';
  }

  static String statusLabel(String? status) {
    if (isCompletedStatus(status)) return 'Завершено';
    return 'В процессе';
  }

  Future<Map<String, dynamic>?> getExamination(String examinationId) async {
    return await client.from('examinations').select().eq('id', examinationId).maybeSingle();
  }

  Future<String?> getPatientIdByExamination(String examinationId) async {
    final examination = await getExamination(examinationId);
    return examination?['patient_id']?.toString();
  }

  bool _hasSelectedPair(Map<String, dynamic>? data, String leftKey, String rightKey) {
    if (data == null) return false;
    final left = (data[leftKey] as num?)?.toInt() ?? 0;
    final right = (data[rightKey] as num?)?.toInt() ?? 0;
    return left == 1 || right == 1;
  }

  bool _isStar1Part1Complete(Map<String, dynamic>? star1) {
    const rows = [
      ['p1', 'c1'],
      ['gi1', 'ig1'],
      ['p2', 'f1'],
      ['gi2', 'vb1'],
      ['p3', 'r1'],
      ['gi3', 'v1'],
      ['p4', 'rp1'],
      ['gi4', 'e1'],
      ['rp2', 'c2'],
      ['e2', 'ig2'],
    ];
    return rows.every((row) => _hasSelectedPair(star1, row[0], row[1]));
  }

  bool _isStar1Part2Complete(Map<String, dynamic>? star1) {
    const rows = [
      ['rp3', 'f2'],
      ['e3', 'vb2'],
      ['rp4', 'r2'],
      ['e4', 'v2'],
      ['r3', 'f3'],
      ['v3', 'vb3'],
      ['f4', 'c3'],
      ['vb4', 'ig3'],
    ];
    return rows.every((row) => _hasSelectedPair(star1, row[0], row[1]));
  }

  bool _isStar2Complete(Map<String, dynamic>? star2) {
    const rows = [
      ['mc1', 'c5'],
      ['tr1', 'ig5'],
      ['mc2', 'f5'],
      ['tr2', 'vb5'],
      ['mc3', 'r5'],
      ['tr3', 'v5'],
      ['mc4', 'rp5'],
      ['tr4', 'e5'],
      ['mc5', 'p5'],
      ['tr5', 'gi5'],
    ];
    return rows.every((row) => _hasSelectedPair(star2, row[0], row[1]));
  }

  bool _isParametersComplete({
    required Map<String, dynamic>? energy,
    required Map<String, dynamic>? p9,
    required Map<String, dynamic>? e42,
    required Map<String, dynamic>? foot,
  }) {
    final energySelected = energy?['selected_cells'];
    final hasEnergy = energy != null &&
        ((energy['result']?.toString().isNotEmpty ?? false) ||
            (energySelected is Map && energySelected['yin_yang_energy'] != null));

    final hasP9 = p9 != null &&
        ((p9['direction']?.toString().isNotEmpty ?? false) ||
            (p9['result']?.toString().isNotEmpty ?? false));

    final e42Selected = e42?['selected_cells'];
    final hasE42 = e42 != null &&
        (e42Selected is Map
            ? e42Selected['chi_cun'] != null && e42Selected['e42'] != null
            : true);

    final footSelected = foot?['selected_cells'];
    final hasFoot = foot != null &&
        (footSelected is Map
            ? footSelected['pulse_depth'] != null &&
                footSelected['pulse_length'] != null &&
                footSelected['pulse_smoothness'] != null
            : (foot['foot_status']?.toString().isNotEmpty ?? false));

    return hasEnergy && hasP9 && hasE42 && hasFoot;
  }

  Future<String> getResumeRoute(String examinationId) async {
    final examination = await getExamination(examinationId);
    if (isCompletedStatus(examination?['status']?.toString())) {
      return '/examinations/$examinationId/result';
    }

    final star1 = await getModule('exam_star1', examinationId);
    if (!_isStar1Part1Complete(star1)) {
      return '/examinations/$examinationId/star1';
    }
    if (!_isStar1Part2Complete(star1)) {
      return '/examinations/$examinationId/star1-part2';
    }

    final star2 = await getModule('exam_star2', examinationId);
    if (!_isStar2Complete(star2)) {
      return '/examinations/$examinationId/star2';
    }

    final energy = await getModule('exam_energy', examinationId);
    final p9 = await getModule('exam_p9', examinationId);
    final e42 = await getModule('exam_e42', examinationId);
    final foot = await getModule('exam_foot', examinationId);
    if (!_isParametersComplete(energy: energy, p9: p9, e42: e42, foot: foot)) {
      return '/examinations/$examinationId/parameters';
    }

    return '/examinations/$examinationId/result';
  }

  Future<void> completeExamination(String examinationId) async {
    await client.from('examinations').update({'status': 'completed'}).eq('id', examinationId);
  }

}
