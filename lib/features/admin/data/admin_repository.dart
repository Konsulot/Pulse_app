import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/admin_models.dart';

class AdminRepository {
  final SupabaseClient client;
  AdminRepository(this.client);

  Future<List<ClinicAdminModel>> getClinics() async {
    final response = await client
        .from('clinics')
        .select('id, short_name, full_name, ogrn, address, phone, email, postal_index, chief_doctor_name, deputy_chief_doctor_name')
        .order('short_name', ascending: true);

    return (response as List)
        .map((item) => ClinicAdminModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createClinic({
    required String shortName,
    String? fullName,
    String? ogrn,
    String? address,
    String? phone,
    String? email,
    int? postalIndex,
    String? chiefDoctorName,
    String? deputyChiefDoctorName,
  }) async {
    await client.from('clinics').insert(<String, dynamic>{
      'short_name': shortName.trim(),
      'full_name': _nullableText(fullName),
      'ogrn': _nullableText(ogrn),
      'address': _nullableText(address),
      'phone': _nullableText(phone),
      'email': _nullableText(email),
      'postal_index': postalIndex,
      'chief_doctor_name': _nullableText(chiefDoctorName),
      'deputy_chief_doctor_name': _nullableText(deputyChiefDoctorName),
    });
  }

  Future<void> updateClinic({
    required String clinicId,
    required String shortName,
    String? fullName,
    String? ogrn,
    String? address,
    String? phone,
    String? email,
    int? postalIndex,
    String? chiefDoctorName,
    String? deputyChiefDoctorName,
  }) async {
    await client.from('clinics').update(<String, dynamic>{
      'short_name': shortName.trim(),
      'full_name': _nullableText(fullName),
      'ogrn': _nullableText(ogrn),
      'address': _nullableText(address),
      'phone': _nullableText(phone),
      'email': _nullableText(email),
      'postal_index': postalIndex,
      'chief_doctor_name': _nullableText(chiefDoctorName),
      'deputy_chief_doctor_name': _nullableText(deputyChiefDoctorName),
    }).eq('id', clinicId);
  }

  Future<void> deleteClinic(String clinicId) async {
    await client.from('clinics').delete().eq('id', clinicId);
  }

  Future<List<DoctorAdminModel>> getDoctors() async {
    final response = await client
        .from('profiles')
        .select('id, full_name, clinic_id, doctor_id, is_active')
        .eq('role', 'doctor')
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => DoctorAdminModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> assignDoctorToClinic({
    required String profileId,
    required String clinicId,
  }) async {
    await client.from('profiles').update(<String, dynamic>{
      'clinic_id': clinicId,
      'doctor_id': null,
      'is_active': true,
    }).eq('id', profileId);
  }

  Future<void> detachDoctorFromClinic(String profileId) async {
    await client.from('profiles').update(<String, dynamic>{
      'clinic_id': null,
      'doctor_id': null,
    }).eq('id', profileId);
  }

  Future<void> disableDoctorAccess(String profileId) async {
    await client.from('profiles').update(<String, dynamic>{
      'is_active': false,
      'clinic_id': null,
      'doctor_id': null,
    }).eq('id', profileId);
  }

  Future<void> enableDoctorAccess(String profileId) async {
    await client.from('profiles').update(<String, dynamic>{
      'is_active': true,
    }).eq('id', profileId);
  }

  String? _nullableText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
