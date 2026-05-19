import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/patient_model.dart';

class PatientsRepository {
  final SupabaseClient client;
  PatientsRepository(this.client);

  Future<String?> _currentClinicId() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    final profile = await client
        .from('profiles')
        .select('clinic_id')
        .eq('id', user.id)
        .maybeSingle();
    return profile?['clinic_id']?.toString();
  }

  Future<List<PatientModel>> getPatients() async {
    final clinicId = await _currentClinicId();
    if (clinicId == null || clinicId.isEmpty) return [];

    final response = await client
        .from('patients')
        .select()
        .eq('clinic_id', clinicId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => PatientModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PatientModel> getPatientById(String id) async {
    final clinicId = await _currentClinicId();
    var query = client.from('patients').select().eq('id', id);
    if (clinicId != null && clinicId.isNotEmpty) {
      query = query.eq('clinic_id', clinicId);
    }
    final response = await query.single();
    return PatientModel.fromJson(response);
  }

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
    final clinicId = await _currentClinicId();
    if (clinicId == null || clinicId.isEmpty) {
      throw Exception('Аккаунт не привязан к клинике. Создание пациентов недоступно.');
    }

    await client.from('patients').insert({
      'clinic_id': clinicId,
      'card_number': cardNumber.trim(),
      'last_name': lastName.trim(),
      'first_name': firstName.trim(),
      'middle_name': _nullableText(middleName),
      'birth_date': birthDate?.toIso8601String().split('T').first,
      'polis': _nullableText(polis),
      'snils': _nullableText(snils),
      'gender_id': genderId,
      'region': _nullableText(region),
      'city': _nullableText(city),
      'street': _nullableText(street),
      'house': house,
      'room': room,
      'postal_index': postalIndex,
      'job': _nullableText(job),
      'job_title': _nullableText(jobTitle),
      'is_disabled': isDisabled,
      'insurance_org_name': _nullableText(insuranceOrgName),
      'education': _nullableText(education),
      'disability_group': disabilityGroup,
    });
  }

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
    final clinicId = await _currentClinicId();
    var query = client.from('patients').update({
      'card_number': cardNumber.trim(),
      'last_name': lastName.trim(),
      'first_name': firstName.trim(),
      'middle_name': _nullableText(middleName),
      'birth_date': birthDate?.toIso8601String().split('T').first,
      'polis': _nullableText(polis),
      'snils': _nullableText(snils),
      'gender_id': genderId,
      'region': _nullableText(region),
      'city': _nullableText(city),
      'street': _nullableText(street),
      'house': house,
      'room': room,
      'postal_index': postalIndex,
      'job': _nullableText(job),
      'job_title': _nullableText(jobTitle),
      'is_disabled': isDisabled,
      'insurance_org_name': _nullableText(insuranceOrgName),
      'education': _nullableText(education),
      'disability_group': disabilityGroup,
    }).eq('id', id);

    if (clinicId != null && clinicId.isNotEmpty) {
      query = query.eq('clinic_id', clinicId);
    }

    await query;
  }

  Future<void> deletePatient(String id) async {
    final clinicId = await _currentClinicId();
    var query = client.from('patients').delete().eq('id', id);
    if (clinicId != null && clinicId.isNotEmpty) {
      query = query.eq('clinic_id', clinicId);
    }
    await query;
  }

  String? _nullableText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
